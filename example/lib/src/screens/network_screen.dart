// Network & Peers: current network (raw), database stats, connected peers.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network & Peers')),
      body: ApiView<
          (GetDatabaseStatsResponse, List<PeerRecord>,
              Map<String, dynamic>)>(
        load: () async {
          final db = await sage.api.getDatabaseStats();
          final peers = (await sage.api.getPeers()).peers;
          final net = await sage.callJson('get_network', {});
          return (db, peers, net);
        },
        builder: (ctx, data, refresh) {
          final (db, peers, net) = data;
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Network',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(
                const JsonEncoder.withIndent('  ').convert(net),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            const Divider(height: 28),
            const Text('Database',
                style: TextStyle(fontWeight: FontWeight.bold)),
            kv('Size', '${db.databaseSizeBytes} B'),
            kv('Free', '${db.freePercentage.toStringAsFixed(1)}%'),
            kv('Pages', '${db.totalPages} (wal ${db.walPages})'),
            const Divider(height: 28),
            Text('Peers (${peers.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final p in peers)
              ListTile(
                dense: true,
                leading: const Icon(Icons.computer),
                title: Text('${p.ipAddr}:${p.port}'),
                subtitle: Text('height ${p.peakHeight}'
                    '${p.userManaged ? ' · manual' : ''}'),
              ),
          ]);
        },
      ),
    );
  }
}
