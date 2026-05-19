// Activity: transaction list → human-readable transaction detail (created vs
// spent coins, per-asset amounts, addresses) with a raw-JSON fallback.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key, required this.api});
  final SageApi api;
  @override
  Widget build(BuildContext context) {
    return ApiView<List<TransactionRecord>>(
      load: () async => (await api.getTransactions(
              GetTransactions(offset: 0, limit: 50, ascending: false)))
          .transactions,
      builder: (ctx, txs, refresh) => txs.isEmpty
          ? ListView(children: const [
              SizedBox(height: 180),
              Center(child: Text('No transactions yet.')),
            ])
          : ListView(children: [
              for (final t in txs)
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('Block ${t.height}'),
                  subtitle: Text(
                      '${t.created.length} created · ${t.spent.length} spent'
                      '${t.timestamp != null ? ' · ${DateTime.fromMillisecondsSinceEpoch(t.timestamp! * 1000)}' : ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) =>
                          TransactionScreen(api: api, height: t.height))),
                ),
            ]),
    );
  }
}

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key, required this.api, required this.height});
  final SageApi api;
  final int height;

  String _shorten(String s, [int head = 10, int tail = 6]) =>
      s.length <= head + tail + 1 ? s : '${s.substring(0, head)}…${s.substring(s.length - tail)}';

  Widget _coinTile(BuildContext ctx, TransactionCoinRecord c, bool incoming) {
    final ticker = c.asset.ticker ?? c.asset.name ?? c.asset.kind.value;
    return ListTile(
      dense: true,
      leading: Icon(incoming ? Icons.south_west : Icons.north_east,
          color: incoming ? Colors.green : Colors.red),
      title: Text('${fmt(c.amount, c.asset.precision)} $ticker'),
      subtitle: Text(
        '${c.addressKind.value}'
        '${c.address != null ? ' · ${_shorten(c.address!)}' : ''}',
      ),
      trailing: Text(_shorten(c.coinId, 6, 4),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction @ $height'), actions: [
        IconButton(
          tooltip: 'Raw JSON',
          icon: const Icon(Icons.data_object),
          onPressed: () async {
            final r = await api.getTransaction(GetTransaction(height: height));
            if (!context.mounted) return;
            showTextDialog(context, 'Raw transaction',
                const JsonEncoder.withIndent('  ').convert(r.toJson()));
          },
        ),
      ]),
      body: ApiView<GetTransactionResponse>(
        load: () => api.getTransaction(GetTransaction(height: height)),
        builder: (ctx, r, refresh) {
          final tx = r.transaction;
          if (tx == null) {
            return ListView(children: const [
              SizedBox(height: 180),
              Center(child: Text('Transaction not found.')),
            ]);
          }
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kv('Block height', '${tx.height}'),
                      if (tx.timestamp != null)
                        kv(
                            'Timestamp',
                            DateTime.fromMillisecondsSinceEpoch(
                                    tx.timestamp! * 1000)
                                .toString()),
                      kv('Created coins', '${tx.created.length}'),
                      kv('Spent coins', '${tx.spent.length}'),
                    ]),
              ),
            ),
            const SizedBox(height: 12),
            if (tx.created.isNotEmpty) ...[
              Text('Created (received)',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final c in tx.created) _coinTile(ctx, c, true),
              const SizedBox(height: 12),
            ],
            if (tx.spent.isNotEmpty) ...[
              Text('Spent (sent)',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final c in tx.spent) _coinTile(ctx, c, false),
            ],
          ]);
        },
      ),
    );
  }
}
