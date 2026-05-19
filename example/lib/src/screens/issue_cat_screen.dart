// Issue CAT: mint a brand-new CAT token (issue_cat). Mirrors Sage Tauri's
// IssueToken screen. Amount is the initial supply in the CAT's own units
// (3 decimals by convention) — entered here in mojos for simplicity.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class IssueCatScreen extends StatefulWidget {
  const IssueCatScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<IssueCatScreen> createState() => _IssueCatScreenState();
}

class _IssueCatScreenState extends State<IssueCatScreen> {
  final _name = TextEditingController();
  final _ticker = TextEditingController();
  final _amount = TextEditingController(text: '1000');
  final _fee = TextEditingController(text: '0');
  bool _busy = false;
  String _result = '';

  Future<void> _issue() async {
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.issueCat(IssueCat(
        name: _name.text.trim(),
        ticker: _ticker.text.trim(),
        amount: mojos(_amount.text),
        fee: mojos(_fee.text),
        autoSubmit: true,
      ));
      setState(() => _result =
          'Submitted ✓\nfee: ${res.summary.fee}\ncoin spends: ${res.coinSpends.length}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue CAT token')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Mints a new CAT. The initial supply is created to your '
            'own wallet. Amount is in the smallest unit.'),
        const SizedBox(height: 16),
        TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Token name')),
        const SizedBox(height: 12),
        TextField(
            controller: _ticker,
            decoration:
                const InputDecoration(labelText: 'Ticker (e.g. MYCAT)')),
        const SizedBox(height: 12),
        TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Initial supply (units)')),
        const SizedBox(height: 12),
        TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fee (mojos)')),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _issue,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.toll),
          label: const Text('issue_cat (auto-submit)'),
        ),
        const SizedBox(height: 16),
        if (_result.isNotEmpty)
          SelectableText(_result,
              style: const TextStyle(fontFamily: 'monospace')),
      ]),
    );
  }
}
