// Active wallet shell: prepares derivations once, then hosts the 5 bottom
// tabs (Overview, Tokens, Send, Activity, More).
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import 'activity_tab.dart';
import 'more_tab.dart';
import 'overview_tab.dart';
import 'send_xch_tab.dart';
import 'tangem_screen.dart';
import 'tokens_tab.dart';

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

  bool get _isArbor => widget.keyInfo.arborOnly == true;

  // Normal wallets: grow HD derivations (idempotent — also repairs
  // 0-derivation wallets). Arbor/Tangem wallets have exactly one puzzle and
  // no derivations, so skip it entirely.
  Future<void> _prepare() async {
    if (_isArbor) {
      setState(() => _ready = true);
      return;
    }
    try {
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
          child: _prep.startsWith('Setup failed')
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_prep,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)))
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_prep),
                ]),
        ),
      );
    }
    final tabs = [
      OverviewTab(sage: widget.sage, keyInfo: widget.keyInfo),
      TokensTab(sage: widget.sage),
      // Arbor/Tangem has no private key: build unsigned spends + show the
      // messages the card must sign. Normal wallets get the usual sender.
      _isArbor
          ? TangemSendTab(sage: widget.sage, keyInfo: widget.keyInfo)
          : SendXchTab(api: _api),
      ActivityTab(api: _api),
      MoreTab(sage: widget.sage, keyInfo: widget.keyInfo),
    ];
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${widget.keyInfo.name}${_isArbor ? ' · Tangem' : ''}'),
          actions: [
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
          NavigationDestination(icon: Icon(Icons.send), label: 'Send'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'More'),
        ],
      ),
    );
  }
}
