import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SageBinding.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SageClient? _sage;
  String _status = 'Initializing Sage…';
  String _output = '';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');
      setState(() {
        _sage = sage;
        _status = 'Sage ready';
      });
    } catch (e) {
      setState(() => _status = 'Init failed: $e');
    }
  }

  Future<void> _generateMnemonic() async {
    final sage = _sage;
    if (sage == null) return;
    try {
      // Generic JSON passthrough — same endpoint names/payloads as Sage RPC.
      final res = await sage.callJson('generate_mnemonic', {
        'use_24_words': true,
      });
      setState(() => _output = res['mnemonic'] as String);
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  Future<void> _getVersion() async {
    final sage = _sage;
    if (sage == null) return;
    try {
      final res = await sage.callJson('get_version');
      setState(() => _output = res.toString());
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _sage != null;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Sage Flutter binding')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: ready ? _generateMnemonic : null,
                child: const Text('generate_mnemonic'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: ready ? _getVersion : null,
                child: const Text('get_version'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
