// API Console: searchable picker over all ~105 Sage endpoints, prefilled
// request JSON, raw response — the generic passthrough escape hatch.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

class ConsoleScreen extends StatefulWidget {
  const ConsoleScreen({super.key, required this.client});
  final SageClient client;
  @override
  State<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  static const _pretty = JsonEncoder.withIndent('  ');
  late SageEndpoint _ep = kSageEndpoints.firstWhere(
      (e) => e.name == 'get_sync_status',
      orElse: () => kSageEndpoints.first);
  final _body = TextEditingController(text: '{}');
  String _out = '';
  bool _busy = false;

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
    return Scaffold(
      appBar: AppBar(title: const Text('API Console')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownMenu<SageEndpoint>(
          initialSelection: _ep,
          expandedInsets: EdgeInsets.zero,
          enableFilter: true,
          requestFocusOnTap: true,
          label: const Text('Endpoint (type to search · 105)'),
          leadingIcon: const Icon(Icons.search),
          onSelected: (e) {
            if (e != null) _select(e);
          },
          dropdownMenuEntries: [
            for (final e in kSageEndpoints)
              DropdownMenuEntry(
                  value: e,
                  label: e.name,
                  labelWidget: Text('${e.name}  ·  ${e.tag}')),
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
              labelText: 'Request JSON (prefilled)', filled: true),
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
      ]),
    );
  }
}
