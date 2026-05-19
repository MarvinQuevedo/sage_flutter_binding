// Addresses: validate an address (check_address) + list HD derivations.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _check = TextEditingController();
  String _checkResult = '';

  Future<void> _doCheck() async {
    try {
      final r = await widget.api
          .checkAddress(CheckAddress(address: _check.text.trim()));
      setState(() => _checkResult = r.valid ? 'Valid ✓' : 'Not valid ✗');
    } catch (e) {
      setState(() => _checkResult = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: _check,
                    decoration: const InputDecoration(
                        labelText: 'check_address (xch1…)'))),
            const SizedBox(width: 8),
            FilledButton(onPressed: _doCheck, child: const Text('Check')),
          ]),
        ),
        if (_checkResult.isNotEmpty) Text(_checkResult),
        const Divider(),
        Expanded(
          child: ApiView<List<DerivationRecord>>(
            load: () async => (await widget.api.getDerivations(
                    GetDerivations(offset: 0, limit: 100, hardened: false)))
                .derivations,
            builder: (ctx, d, refresh) => ListView(children: [
              for (final r in d)
                ListTile(
                  dense: true,
                  leading: Text('#${r.index}'),
                  title: SelectableText(r.address,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12)),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}
