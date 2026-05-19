import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SageBinding.init();
  runApp(const SageDemoApp());
}

class SageDemoApp extends StatelessWidget {
  const SageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sage Wallet (demo)',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C4B9A),
        useMaterial3: true,
      ),
      home: const BootGate(),
    );
  }
}

/// Initializes a Sage instance, then shows the wallet UI.
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
      return Scaffold(
        body: Center(child: Text('Sage failed to start:\n$_error')),
      );
    }
    if (_sage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return KeysScreen(sage: _sage!);
  }
}

/// Lists wallet keys; lets you create / import / select / delete them.
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
      await _api.importKey(ImportKey(name: name, key: m.mnemonic, login: true));
      await _showMnemonic(m.mnemonic);
      final res = await _api.getKeys();
      setState(() => _keys = res.keys);
    });
  }

  Future<void> _importWallet() async {
    final name = await _prompt('Wallet name', initial: 'Imported');
    if (name == null || name.isEmpty) return;
    final phrase = await _prompt('Mnemonic phrase (12/24 words)');
    if (phrase == null || phrase.trim().isEmpty) return;
    await _run(() async {
      await _api.importKey(
        ImportKey(name: name, key: phrase.trim(), login: true),
      );
      final res = await _api.getKeys();
      setState(() => _keys = res.keys);
    });
  }

  Future<void> _open(KeyInfo key) async {
    await _run(() => _api.login(Login(fingerprint: key.fingerprint)));
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletScreen(sage: widget.sage, keyInfo: key),
      ),
    );
    _refresh();
  }

  Future<void> _delete(KeyInfo key) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete "${key.name}"?'),
        content: const Text('This removes the key from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() async {
      await _api.deleteKey(DeleteKey(fingerprint: key.fingerprint));
      final res = await _api.getKeys();
      setState(() => _keys = res.keys);
    });
  }

  Future<String?> _prompt(String title, {String initial = ''}) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, ctrl.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMnemonic(String mnemonic) {
    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Save your recovery phrase'),
        content: SelectableText(
          mnemonic,
          style: const TextStyle(fontFamily: 'monospace', height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('I saved it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sage Wallets'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(_error!),
            ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _keys.isEmpty && !_loading
                ? const Center(child: Text('No wallets yet. Create one below.'))
                : ListView(
                    children: [
                      for (final k in _keys)
                        ListTile(
                          leading: Text(
                            k.emoji ?? '🔑',
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(k.name),
                          subtitle: Text(
                            'fingerprint ${k.fingerprint} · '
                            '${k.kind.value} · ${k.networkId}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(k),
                          ),
                          onTap: () => _open(k),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'import',
            onPressed: _loading ? null : _importWallet,
            icon: const Icon(Icons.download),
            label: const Text('Import'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: _loading ? null : _createWallet,
            icon: const Icon(Icons.add),
            label: const Text('New wallet'),
          ),
        ],
      ),
    );
  }
}

/// Shows the active wallet's receive address, balance and sync status.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.sage, required this.keyInfo});
  final SageClient sage;
  final KeyInfo keyInfo;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  SageApi get _api => widget.sage.api;
  GetSyncStatusResponse? _status;
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _refresh();
    // The wallet syncs in the background; poll so the balance updates.
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final s = await _api.getSyncStatus();
      if (mounted) setState(() => _status = s);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  String _formatBalance(BigInt mojos, int precision) {
    final divisor = BigInt.from(10).pow(precision);
    final whole = mojos ~/ divisor;
    final frac = (mojos % divisor).toString().padLeft(precision, '0');
    final trimmed = frac.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? '$whole' : '$whole.$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keyInfo.name),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _api.logout();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
                ),
              ),
            if (s == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spendable balance'),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatBalance(s.selectableBalance, s.unit.precision)}'
                        ' ${s.unit.ticker}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receive address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        s.receiveAddress,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow('Synced coins', '${s.syncedCoins} / ${s.totalCoins}'),
              _InfoRow('Checked files', '${s.checkedFiles} / ${s.totalFiles}'),
              _InfoRow(
                'Derivation (unhardened)',
                '${s.unhardenedDerivationIndex}',
              ),
              _InfoRow('Network', widget.keyInfo.networkId),
              const SizedBox(height: 16),
              const Text(
                'The wallet syncs with Chia peers in the background; '
                'this view refreshes every 5s.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
