// Receive: QR of the wallet's current receive address + copy. Mirrors Sage
// Tauri's receive flow (which also just renders the sync-status address).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../common.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key, required this.address, required this.name});
  final String address;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: address,
                version: QrVersions.auto,
                size: 260,
                gapless: true,
              ),
            ),
            const SizedBox(height: 24),
            SelectableText(
              address,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: address));
                if (context.mounted) toast(context, 'Address copied');
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy address'),
            ),
          ]),
        ),
      ),
    );
  }
}
