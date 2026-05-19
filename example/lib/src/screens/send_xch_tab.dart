// Send XCH: check_address (replaces Sage's Tauri validate_address) → send_xch.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class SendXchTab extends StatefulWidget {
  const SendXchTab({super.key, required this.api});
  final SageApi api;
  @override
  State<SendXchTab> createState() => _SendXchTabState();
}

class _SendXchTabState extends State<SendXchTab> {
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
      // Validate first (replaces Sage's Tauri validate_address).
      final chk = await widget.api
          .checkAddress(CheckAddress(address: _addr.text.trim()));
      if (!chk.valid) {
        setState(() => _result = 'Invalid address for this network');
        return;
      }
      final res = await widget.api.sendXch(SendXch(
        address: _addr.text.trim(),
        amount: parseAmount(_amount.text, kXchPrecision),
        fee: mojos(_fee.text),
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
        label: const Text('check_address → send_xch'),
      ),
      const SizedBox(height: 20),
      if (_result.isNotEmpty)
        SelectableText(_result,
            style: const TextStyle(fontFamily: 'monospace')),
    ]);
  }
}
