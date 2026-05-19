// WalletConnect endpoints — the 5 ex-"tauri" endpoints, now first-class on
// the typed API. (The WalletConnect *protocol* itself is frontend/JS in
// Sage's Tauri build; only these wallet primitives live in Rust.)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  final _msg = TextEditingController(text: 'Hello from Sage');
  String _out = '';
  bool _busy = false;

  Future<void> _run(Future<String> Function() f) async {
    setState(() {
      _busy = true;
      _out = '';
    });
    try {
      _out = await f();
    } catch (e) {
      _out = 'Error: $e';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WalletConnect endpoints')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('The 5 ex-"tauri" endpoints, now first-class.'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _run(() async {
                    // get_asset_coins uses camelCase JSON keys.
                    final r = await widget.sage.callJson(
                        'get_asset_coins', {'type': 'cat', 'limit': 5});
                    return const JsonEncoder.withIndent('  ').convert(r);
                  }),
          child: const Text('get_asset_coins (type: cat)'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _run(() async {
                    final r = await widget.sage.api.filterUnlockedCoins(
                        FilterUnlockedCoins(coinIds: const []));
                    return 'unlocked coin ids: ${r.coinIds.length}';
                  }),
          child: const Text('filter_unlocked_coins ([])'),
        ),
        const Divider(height: 28),
        TextField(
            controller: _msg,
            decoration: const InputDecoration(labelText: 'Message to sign')),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _run(() async {
                    // Sign with the wallet's current receive address.
                    final st = await widget.sage.api.getSyncStatus();
                    final r = await widget.sage.api.signMessageByAddress(
                        SignMessageByAddress(
                            message: _msg.text,
                            address: st.receiveAddress));
                    return 'pubkey: ${r.publicKey}\n\nsignature:\n${r.signature}';
                  }),
          child: const Text('sign_message_by_address'),
        ),
        const SizedBox(height: 16),
        if (_busy) const Center(child: CircularProgressIndicator()),
        if (_out.isNotEmpty)
          SelectableText(_out,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      ]),
    );
  }
}
