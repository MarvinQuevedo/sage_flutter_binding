// Wallet overview: polled get_sync_status, balance, receive address with a
// shortcut to the QR Receive screen.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';
import 'receive_screen.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key, required this.sage, required this.keyInfo});
  final SageClient sage;
  final KeyInfo keyInfo;
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
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
      final s = await widget.sage.api.getSyncStatus();
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
                    Text(
                        '${fmt(s.selectableBalance, s.unit.precision)} ${s.unit.ticker}',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ReceiveScreen(
                    address: s.receiveAddress, name: widget.keyInfo.name))),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Receive'),
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
          kv('Synced coins', '${s.syncedCoins} / ${s.totalCoins}'),
          kv('Checked files', '${s.checkedFiles} / ${s.totalFiles}'),
          kv('Unhardened index', '${s.unhardenedDerivationIndex}'),
          kv('Hardened index', '${s.hardenedDerivationIndex}'),
          kv('Database size', '${s.databaseSize} B'),
          kv('Network', widget.keyInfo.networkId),
          const SizedBox(height: 12),
          const Text('Polls get_sync_status every 4s (no event stream yet).',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }
}
