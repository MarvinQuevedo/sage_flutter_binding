// Tokens tab: CAT list → CAT detail (balance + coins) → send CAT.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class TokensTab extends StatelessWidget {
  const TokensTab({super.key, required this.sage});
  final SageClient sage;
  @override
  Widget build(BuildContext context) {
    return ApiView<List<TokenRecord>>(
      load: () async => (await sage.api.getCats()).cats,
      builder: (ctx, cats, refresh) => cats.isEmpty
          ? ListView(children: const [
              SizedBox(height: 180),
              Center(child: Text('No CAT tokens for this wallet.')),
            ])
          : ListView(children: [
              for (final t in cats)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.toll)),
                  title: Text(t.name ?? t.ticker ?? 'CAT'),
                  subtitle: Text(
                      '${fmt(t.balance, t.precision)} ${t.ticker ?? ''} · spendable ${fmt(t.selectableBalance, t.precision)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: t.assetId == null
                      ? null
                      : () => Navigator.of(ctx).push(MaterialPageRoute(
                          builder: (_) =>
                              CatDetailScreen(sage: sage, token: t))),
                ),
            ]),
    );
  }
}

class CatDetailScreen extends StatelessWidget {
  const CatDetailScreen({super.key, required this.sage, required this.token});
  final SageClient sage;
  final TokenRecord token;
  @override
  Widget build(BuildContext context) {
    final t = token;
    return Scaffold(
      appBar: AppBar(title: Text(t.name ?? t.ticker ?? 'CAT')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SendCatScreen(api: sage.api, token: t))),
        icon: const Icon(Icons.send),
        label: const Text('Send CAT'),
      ),
      body: ApiView<List<CoinRecord>>(
        load: () async => (await sage.api.getCoins(
                GetCoins(assetId: t.assetId, offset: 0, limit: 100)))
            .coins,
        builder: (ctx, coins, refresh) =>
            ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${fmt(t.balance, t.precision)} ${t.ticker ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    kv('Spendable', fmt(t.selectableBalance, t.precision)),
                    kv('Precision', '${t.precision}'),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Asset ID',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(t.assetId ?? '—',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const Divider(height: 32),
          Text('Coins (${coins.length})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          for (final c in coins)
            ListTile(
              dense: true,
              title: Text('${fmt(c.amount, t.precision)} ${t.ticker ?? ''}'),
              subtitle:
                  Text(c.coinId, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(c.spentHeight != null ? 'spent' : 'unspent',
                  style: TextStyle(
                      color: c.spentHeight != null
                          ? Colors.red
                          : Colors.green)),
            ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

class SendCatScreen extends StatefulWidget {
  const SendCatScreen({super.key, required this.api, required this.token});
  final SageApi api;
  final TokenRecord token;
  @override
  State<SendCatScreen> createState() => _SendCatScreenState();
}

class _SendCatScreenState extends State<SendCatScreen> {
  final _addr = TextEditingController();
  final _amount = TextEditingController(text: '0');
  final _fee = TextEditingController(text: '0');
  String _result = '';
  bool _busy = false;

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.sendCat(SendCat(
        address: _addr.text.trim(),
        amount: parseAmount(_amount.text, widget.token.precision),
        assetId: widget.token.assetId!,
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
    final t = widget.token;
    return Scaffold(
      appBar: AppBar(title: Text('Send ${t.ticker ?? t.name ?? 'CAT'}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Balance: ${fmt(t.balance, t.precision)} ${t.ticker ?? ''}'),
        const SizedBox(height: 16),
        TextField(
            controller: _addr,
            decoration:
                const InputDecoration(labelText: 'Recipient address')),
        const SizedBox(height: 12),
        TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(labelText: 'Amount (${t.ticker ?? 'CAT'})')),
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
          label: const Text('Send CAT (auto-submit)'),
        ),
        const SizedBox(height: 20),
        if (_result.isNotEmpty)
          SelectableText(_result,
              style: const TextStyle(fontFamily: 'monospace')),
      ]),
    );
  }
}
