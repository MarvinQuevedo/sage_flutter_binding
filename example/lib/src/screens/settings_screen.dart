// Settings: switch the active Chia network (mainnet / testnet11 / …).
// get_networks + get_network return untyped JSON (Sage exposes them as raw
// maps), so we parse defensively and switch with set_network.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _networks = [];
  String? _current;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// get_networks may be a map keyed by name, a {"networks":[...]} wrapper,
  /// or a list — normalise all of them to a list of names.
  List<String> _names(Map<String, dynamic> raw) {
    final inner = raw['networks'] ?? raw;
    if (inner is Map) return inner.keys.map((e) => '$e').toList();
    if (inner is List) {
      return inner
          .map((e) => e is Map ? '${e['name'] ?? e}' : '$e')
          .toList();
    }
    return const [];
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final nets = await widget.sage.api.getNetworks();
      final cur = await widget.sage.api.getNetwork();
      setState(() {
        _networks = _names(nets);
        _current = '${cur['network_id'] ?? cur['name'] ?? cur['default_network'] ?? ''}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _switch(String name) async {
    if (!await confirm(context, 'Switch to "$name"?',
        body: 'The wallet will resync against the new network.',
        confirmLabel: 'Switch')) {
      return;
    }
    try {
      await widget.sage.api.setNetwork(SetNetwork(name: name));
      if (mounted) toast(context, 'Switched to $name');
      await _load();
    } catch (e) {
      if (mounted) toast(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(padding: const EdgeInsets.all(8), children: [
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text('Network',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (final n in _networks)
                  ListTile(
                    leading: Icon(n == _current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked),
                    title: Text(n),
                    selected: n == _current,
                    onTap: n == _current ? null : () => _switch(n),
                  ),
                if (_networks.isEmpty && _error.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No networks reported by get_networks.'),
                  ),
              ]),
      ),
    );
  }
}
