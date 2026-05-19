// NFTs: list → detail (data URIs / collection) → transfer to an address.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class NftsScreen extends StatelessWidget {
  const NftsScreen({super.key, required this.api});
  final SageApi api;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFTs')),
      body: ApiView<List<NftRecord>>(
        load: () async => (await api.getNfts(GetNfts(
                offset: 0,
                limit: 50,
                includeHidden: false,
                sortMode: NftSortMode.name)))
            .nfts,
        builder: (ctx, nfts, refresh) => nfts.isEmpty
            ? ListView(children: const [
                SizedBox(height: 180),
                Center(child: Text('No NFTs in this wallet.')),
              ])
            : ListView(children: [
                for (final n in nfts)
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(n.name ?? n.collectionName ?? 'NFT'),
                    subtitle: Text(n.coinId,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => NftDetailScreen(api: api, nft: n))),
                  ),
              ]),
      ),
    );
  }
}

class NftDetailScreen extends StatefulWidget {
  const NftDetailScreen({super.key, required this.api, required this.nft});
  final SageApi api;
  final NftRecord nft;
  @override
  State<NftDetailScreen> createState() => _NftDetailScreenState();
}

class _NftDetailScreenState extends State<NftDetailScreen> {
  bool _busy = false;
  String _result = '';

  Future<void> _transfer() async {
    final addr = await promptText(context, 'Transfer NFT to address',
        hint: 'xch1…');
    if (addr == null || addr.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.transferNfts(TransferNfts(
        nftIds: [widget.nft.launcherId],
        address: addr.trim(),
        fee: BigInt.zero,
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
    final n = widget.nft;
    return Scaffold(
      appBar: AppBar(title: Text(n.name ?? 'NFT')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kv('Name', n.name ?? '—'),
                  kv('Collection', n.collectionName ?? '—'),
                  kv('Edition',
                      '${n.editionNumber ?? '—'} / ${n.editionTotal ?? '—'}'),
                  kv('Royalty',
                      '${(n.royaltyTenThousandths / 100).toStringAsFixed(2)}%'),
                ]),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Launcher ID',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText(n.launcherId,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        if (n.dataUris.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Data URIs',
              style: TextStyle(fontWeight: FontWeight.bold)),
          for (final u in n.dataUris)
            SelectableText(u,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _transfer,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send),
          label: const Text('Transfer NFT'),
        ),
        const SizedBox(height: 16),
        if (_result.isNotEmpty)
          SelectableText(_result,
              style: const TextStyle(fontFamily: 'monospace')),
      ]),
    );
  }
}
