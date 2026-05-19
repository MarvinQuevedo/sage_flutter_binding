import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SageBinding.init();
  runApp(const SageDemoApp());
}

// XCH uses 12 decimals (mojos). CATs use their own (usually 3).
const int kXchPrecision = 12;

String formatAmount(BigInt v, int precision) {
  final d = BigInt.from(10).pow(precision);
  final w = v ~/ d;
  final f = (v % d)
      .toString()
      .padLeft(precision, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return f.isEmpty ? '$w' : '$w.$f';
}

BigInt parseAmount(String s, int precision) {
  final parts = s.trim().split('.');
  final whole = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
  var frac = parts.length > 1 ? parts[1] : '';
  frac = frac.padRight(precision, '0').substring(0, precision);
  return whole * BigInt.from(10).pow(precision) +
      (frac.isEmpty ? BigInt.zero : BigInt.parse(frac));
}

class SageDemoApp extends StatelessWidget {
  const SageDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sage Wallet (demo)',
      theme: ThemeData(
          colorSchemeSeed: const Color(0xFF5C4B9A), useMaterial3: true),
      home: const BootGate(),
    );
  }
}

class BootGate extends StatefulWidget {
  const BootGate({super.key});
  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  SageClient? _sage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');
      setState(() => _sage = sage);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Sage failed:\n$_error')));
    }
    if (_sage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return KeysScreen(sage: _sage!);
  }
}

class KeysScreen extends StatefulWidget {
  const KeysScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  SageApi get _api => widget.sage.api;
  List<KeyInfo> _keys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() => _run(() async {
        final res = await _api.getKeys();
        setState(() => _keys = res.keys);
      });

  Future<void> _createWallet() async {
    final name = await _prompt('New wallet name', initial: 'My Wallet');
    if (name == null || name.isEmpty) return;
    await _run(() async {
      final m = await _api.generateMnemonic(GenerateMnemonic(use24Words: true));
      // derivationIndex births the wallet with addresses (avoids the
      // "Insufficient derivations" error on first sync).
      await _api.importKey(ImportKey(
          name: name, key: m.mnemonic, login: true, derivationIndex: 1000));
      await _showText('Save your recovery phrase', m.mnemonic);
      _keys = (await _api.getKeys()).keys;
    });
  }

  Future<void> _importWallet() async {
    final name = await _prompt('Wallet name', initial: 'Imported');
    if (name == null || name.isEmpty) return;
    final phrase = await _prompt('Mnemonic phrase (12/24 words)');
    if (phrase == null || phrase.trim().isEmpty) return;
    await _run(() async {
      await _api.importKey(ImportKey(
          name: name,
          key: phrase.trim(),
          login: true,
          derivationIndex: 1000));
      _keys = (await _api.getKeys()).keys;
    });
  }

  Future<void> _open(KeyInfo k) async {
    await _run(() => _api.login(Login(fingerprint: k.fingerprint)));
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WalletScreen(sage: widget.sage, keyInfo: k)));
    _refresh();
  }

  Future<void> _delete(KeyInfo k) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (x) => AlertDialog(
        title: Text('Delete "${k.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(x, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(x, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() async {
      await _api.deleteKey(DeleteKey(fingerprint: k.fingerprint));
      _keys = (await _api.getKeys()).keys;
    });
  }

  Future<String?> _prompt(String title, {String initial = ''}) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (x) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(x, c.text),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _showText(String title, String body) => showDialog<void>(
        context: context,
        builder: (x) => AlertDialog(
          title: Text(title),
          content: SelectableText(body,
              style: const TextStyle(fontFamily: 'monospace', height: 1.5)),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(x),
                child: const Text('Done')),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sage Wallets'), actions: [
        IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh)),
      ]),
      body: Column(children: [
        if (_error != null)
          Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(_error!)),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: _keys.isEmpty && !_loading
              ? const Center(child: Text('No wallets yet — create one.'))
              : ListView(children: [
                  for (final k in _keys)
                    ListTile(
                      leading: Text(k.emoji ?? '🔑',
                          style: const TextStyle(fontSize: 24)),
                      title: Text(k.name),
                      subtitle: Text(
                          'fp ${k.fingerprint} · ${k.kind.value} · ${k.networkId}'),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(k)),
                      onTap: () => _open(k),
                    ),
                ]),
        ),
      ]),
      floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
                heroTag: 'imp',
                onPressed: _loading ? null : _importWallet,
                icon: const Icon(Icons.download),
                label: const Text('Import')),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
                heroTag: 'new',
                onPressed: _loading ? null : _createWallet,
                icon: const Icon(Icons.add),
                label: const Text('New')),
          ]),
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.sage, required this.keyInfo});
  final SageClient sage;
  final KeyInfo keyInfo;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  SageApi get _api => widget.sage.api;
  int _tab = 0;
  bool _ready = false;
  String _prep = 'Preparing wallet…';

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  /// Always ensure derivations exist. `increase_derivation_index` is
  /// idempotent (it only fills the gap to `index`), so this both fixes
  /// freshly-imported wallets and repairs old ones created with 0
  /// derivations. Errors are surfaced, not swallowed.
  Future<void> _prepare() async {
    try {
      setState(() => _prep = 'Generating addresses…');
      await _api.increaseDerivationIndex(IncreaseDerivationIndex(
          index: 1000, hardened: true, unhardened: true));
      setState(() => _ready = true);
    } catch (e) {
      setState(() => _prep = 'Setup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.keyInfo.name)),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_prep.startsWith('Setup failed'))
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_prep,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              )
            else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_prep),
            ],
          ]),
        ),
      );
    }
    final tabs = [
      _OverviewTab(api: _api, keyInfo: widget.keyInfo),
      _TokensTab(sage: widget.sage),
      _SendXchTab(api: _api),
      _ConsoleTab(client: widget.sage),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.keyInfo.name), actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await _api.logout();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ]),
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.toll), label: 'Tokens'),
          NavigationDestination(icon: Icon(Icons.send), label: 'Send XCH'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Console'),
        ],
      ),
    );
  }
}

Widget _kv(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: const TextStyle(color: Colors.black54)),
        Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );

class _OverviewTab extends StatefulWidget {
  const _OverviewTab({required this.api, required this.keyInfo});
  final SageApi api;
  final KeyInfo keyInfo;
  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  GetSyncStatusResponse? _s;
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _refresh();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final s = await widget.api.getSyncStatus();
      if (mounted) {
        setState(() {
          _s = s;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (_error != null)
          Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                  padding: const EdgeInsets.all(12), child: Text(_error!))),
        if (s == null && _error == null)
          const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator())),
        if (s != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spendable XCH'),
                    const SizedBox(height: 4),
                    Text(
                        '${formatAmount(s.selectableBalance, s.unit.precision)} ${s.unit.ticker}',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Receive address',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    SelectableText(s.receiveAddress,
                        style: const TextStyle(fontFamily: 'monospace')),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          _kv('Synced coins', '${s.syncedCoins} / ${s.totalCoins}'),
          _kv('Checked files', '${s.checkedFiles} / ${s.totalFiles}'),
          _kv('Unhardened index', '${s.unhardenedDerivationIndex}'),
          _kv('Hardened index', '${s.hardenedDerivationIndex}'),
          _kv('Database size', '${s.databaseSize} B'),
          _kv('Network', widget.keyInfo.networkId),
          const SizedBox(height: 14),
          const Text('Syncs with Chia peers in the background (refresh 4s).',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }
}

class _TokensTab extends StatefulWidget {
  const _TokensTab({required this.sage});
  final SageClient sage;
  @override
  State<_TokensTab> createState() => _TokensTabState();
}

class _TokensTabState extends State<_TokensTab> {
  List<TokenRecord>? _cats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await widget.sage.api.getCats();
      if (mounted) {
        setState(() {
          _cats = r.cats;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Center(child: Text(_error!));
    final cats = _cats;
    if (cats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: cats.isEmpty
          ? ListView(children: const [
              SizedBox(height: 200),
              Center(child: Text('No CAT tokens for this wallet.')),
            ])
          : ListView(children: [
              for (final t in cats)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.toll)),
                  title: Text(t.name ?? t.ticker ?? 'CAT'),
                  subtitle: Text(
                    '${formatAmount(t.balance, t.precision)} ${t.ticker ?? ''}'
                    '  ·  spendable ${formatAmount(t.selectableBalance, t.precision)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: t.assetId == null
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              CatDetailScreen(sage: widget.sage, token: t))),
                ),
            ]),
    );
  }
}

/// Per-CAT: balance, asset id, the CAT's coins, and a send form.
class CatDetailScreen extends StatefulWidget {
  const CatDetailScreen({super.key, required this.sage, required this.token});
  final SageClient sage;
  final TokenRecord token;
  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  SageApi get _api => widget.sage.api;
  List<CoinRecord>? _coins;
  String? _error;

  TokenRecord get t => widget.token;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      final r = await _api.getCoins(GetCoins(
        assetId: t.assetId,
        offset: 0,
        limit: 100,
      ));
      if (mounted) setState(() => _coins = r.coins);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = _coins;
    return Scaffold(
      appBar: AppBar(title: Text(t.name ?? t.ticker ?? 'CAT')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SendCatScreen(api: _api, token: t))),
        icon: const Icon(Icons.send),
        label: const Text('Send CAT'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCoins,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Balance'),
                    Text('${formatAmount(t.balance, t.precision)} ${t.ticker ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    _kv('Spendable',
                        formatAmount(t.selectableBalance, t.precision)),
                    _kv('Precision', '${t.precision}'),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Asset ID',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SelectableText(t.assetId ?? '—',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const Divider(height: 32),
          Text('Coins (${coins?.length ?? '…'})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_error != null) Text(_error!),
          if (coins == null && _error == null)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator())),
          if (coins != null)
            for (final c in coins)
              ListTile(
                dense: true,
                title: Text('${formatAmount(c.amount, t.precision)} ${t.ticker ?? ''}'),
                subtitle: Text(c.coinId,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(c.spentHeight != null ? 'spent' : 'unspent',
                    style: TextStyle(
                        color: c.spentHeight != null
                            ? Colors.red
                            : Colors.green)),
              ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class SendCatScreen extends StatefulWidget {
  const SendCatScreen({super.key, required this.api, required this.token});
  final SageApi api;
  final TokenRecord token;
  @override
  State<SendCatScreen> createState() => _SendCatScreenState();
}

class _SendCatScreenState extends State<SendCatScreen> {
  final _addr = TextEditingController();
  final _amount = TextEditingController(text: '0');
  final _fee = TextEditingController(text: '0');
  String _result = '';
  bool _busy = false;

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.sendCat(SendCat(
        address: _addr.text.trim(),
        amount: parseAmount(_amount.text, widget.token.precision),
        assetId: widget.token.assetId!,
        fee: BigInt.parse(_fee.text.trim().isEmpty ? '0' : _fee.text.trim()),
        autoSubmit: true,
      ));
      setState(() => _result =
          'Submitted ✓\nfee: ${res.summary.fee}\ninputs: ${res.summary.inputs.length}\ncoin spends: ${res.coinSpends.length}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.token;
    return Scaffold(
      appBar: AppBar(title: Text('Send ${t.ticker ?? t.name ?? 'CAT'}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Balance: ${formatAmount(t.balance, t.precision)} ${t.ticker ?? ''}'),
        const SizedBox(height: 16),
        TextField(
            controller: _addr,
            decoration:
                const InputDecoration(labelText: 'Recipient address')),
        const SizedBox(height: 12),
        TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Amount (${t.ticker ?? 'CAT'})')),
        const SizedBox(height: 12),
        TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fee (mojos, XCH)')),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _send,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send),
          label: const Text('Send CAT (auto-submit)'),
        ),
        const SizedBox(height: 20),
        if (_result.isNotEmpty)
          SelectableText(_result,
              style: const TextStyle(fontFamily: 'monospace')),
      ]),
    );
  }
}

class _SendXchTab extends StatefulWidget {
  const _SendXchTab({required this.api});
  final SageApi api;
  @override
  State<_SendXchTab> createState() => _SendXchTabState();
}

class _SendXchTabState extends State<_SendXchTab> {
  final _addr = TextEditingController();
  final _amount = TextEditingController(text: '0.0');
  final _fee = TextEditingController(text: '0');
  String _result = '';
  bool _busy = false;

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.sendXch(SendXch(
        address: _addr.text.trim(),
        amount: parseAmount(_amount.text, kXchPrecision),
        fee: BigInt.parse(_fee.text.trim().isEmpty ? '0' : _fee.text.trim()),
        autoSubmit: true,
      ));
      setState(() => _result =
          'Submitted ✓\nfee: ${res.summary.fee}\ninputs: ${res.summary.inputs.length}\ncoin spends: ${res.coinSpends.length}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextField(
          controller: _addr,
          decoration:
              const InputDecoration(labelText: 'Recipient address (xch1…)')),
      const SizedBox(height: 12),
      TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (XCH)')),
      const SizedBox(height: 12),
      TextField(
          controller: _fee,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Fee (mojos)')),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: _busy ? null : _send,
        icon: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.send),
        label: const Text('Send XCH (auto-submit)'),
      ),
      const SizedBox(height: 20),
      if (_result.isNotEmpty)
        SelectableText(_result,
            style: const TextStyle(fontFamily: 'monospace')),
    ]);
  }
}

class _ConsoleTab extends StatefulWidget {
  const _ConsoleTab({required this.client});
  final SageClient client;
  @override
  State<_ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends State<_ConsoleTab> {
  static final _pretty = const JsonEncoder.withIndent('  ');
  late SageEndpoint _ep = kSageEndpoints.firstWhere(
      (e) => e.name == 'get_sync_status',
      orElse: () => kSageEndpoints.first);
  final _body = TextEditingController(text: '{}');
  String _out = '';
  bool _busy = false;

  // A few high-traffic shortcuts.
  static const _quick = [
    'get_sync_status',
    'get_keys',
    'get_cats',
    'get_coins',
    'get_transactions',
    'get_nfts',
    'check_address',
  ];

  @override
  void initState() {
    super.initState();
    _select(_ep);
  }

  void _select(SageEndpoint e) {
    setState(() {
      _ep = e;
      try {
        _body.text = _pretty.convert(jsonDecode(e.template));
      } catch (_) {
        _body.text = e.template;
      }
    });
  }

  Future<void> _call() async {
    setState(() {
      _busy = true;
      _out = '';
    });
    try {
      Map<String, dynamic> req;
      try {
        req = (jsonDecode(_body.text) as Map).cast<String, dynamic>();
      } catch (_) {
        req = {};
      }
      final res = await widget.client.callJson(_ep.name, req);
      setState(() => _out = _pretty.convert(res));
    } catch (e) {
      setState(() => _out = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Wrap(spacing: 8, children: [
        for (final q in _quick)
          ActionChip(
            label: Text(q),
            onPressed: () => _select(
                kSageEndpoints.firstWhere((e) => e.name == q)),
          ),
      ]),
      const SizedBox(height: 12),
      // Searchable selector over all 100 endpoints.
      DropdownMenu<SageEndpoint>(
        initialSelection: _ep,
        expandedInsets: EdgeInsets.zero,
        enableFilter: true,
        requestFocusOnTap: true,
        label: const Text('Endpoint (type to search · 100 total)'),
        leadingIcon: const Icon(Icons.search),
        onSelected: (e) {
          if (e != null) _select(e);
        },
        dropdownMenuEntries: [
          for (final e in kSageEndpoints)
            DropdownMenuEntry(
              value: e,
              label: e.name,
              labelWidget: Text('${e.name}  ·  ${e.tag}'),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text('${_ep.tag} — ${_ep.description}',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      TextField(
        controller: _body,
        maxLines: 5,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: const InputDecoration(
            labelText: 'Request JSON (prefilled template)', filled: true),
      ),
      const SizedBox(height: 14),
      FilledButton.icon(
        onPressed: _busy ? null : _call,
        icon: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow),
        label: Text('Call  ${_ep.name}'),
      ),
      const SizedBox(height: 16),
      if (_out.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SelectableText(_out,
              style:
                  const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
    ]);
  }
}
