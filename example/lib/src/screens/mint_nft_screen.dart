// Mint NFT: bulk_mint_nfts under one of the wallet's DIDs. Mirrors Sage
// Tauri's MintNft screen (single mint here for clarity). NFTs are minted
// into a DID "profile", so one must exist first (see DIDs screen).
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class MintNftScreen extends StatefulWidget {
  const MintNftScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<MintNftScreen> createState() => _MintNftScreenState();
}

class _MintNftScreenState extends State<MintNftScreen> {
  final _dataUri = TextEditingController();
  final _dataHash = TextEditingController();
  final _metaUri = TextEditingController();
  final _royalty = TextEditingController(text: '0');
  final _fee = TextEditingController(text: '0');

  List<DidRecord> _dids = [];
  String? _didId;
  bool _loading = true;
  bool _busy = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadDids();
  }

  Future<void> _loadDids() async {
    try {
      final dids = (await widget.api.getDids()).dids;
      setState(() {
        _dids = dids;
        _didId = dids.isEmpty ? null : dids.first.launcherId;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = 'Error loading DIDs: $e';
      });
    }
  }

  Future<void> _mint() async {
    if (_didId == null) return;
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.bulkMintNfts(BulkMintNfts(
        didId: _didId!,
        fee: mojos(_fee.text),
        autoSubmit: true,
        mints: [
          NftMint(
            dataUris:
                _dataUri.text.trim().isEmpty ? null : [_dataUri.text.trim()],
            dataHash:
                _dataHash.text.trim().isEmpty ? null : _dataHash.text.trim(),
            metadataUris:
                _metaUri.text.trim().isEmpty ? null : [_metaUri.text.trim()],
            royaltyTenThousandths:
                int.tryParse(_royalty.text.trim()) ?? 0,
            editionNumber: 1,
            editionTotal: 1,
          ),
        ],
      ));
      setState(() => _result =
          'Minted ✓\nnft_ids: ${res.nftIds.join(', ')}\nfee: ${res.summary.fee}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mint NFT')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _dids.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'No DID profile yet. Create one in "DIDs / Profiles" '
                      'first — NFTs are minted under a DID.',
                      textAlign: TextAlign.center),
                ))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  DropdownButtonFormField<String>(
                    initialValue: _didId,
                    decoration:
                        const InputDecoration(labelText: 'Mint under DID'),
                    items: [
                      for (final d in _dids)
                        DropdownMenuItem(
                          value: d.launcherId,
                          child: Text(d.name ?? d.launcherId),
                        ),
                    ],
                    onChanged: (v) => setState(() => _didId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _dataUri,
                      decoration: const InputDecoration(
                          labelText: 'Data URI (image URL)')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _dataHash,
                      decoration: const InputDecoration(
                          labelText: 'Data hash (sha256 hex, optional)')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _metaUri,
                      decoration: const InputDecoration(
                          labelText: 'Metadata URI (optional)')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _royalty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText:
                              'Royalty (ten-thousandths, 300 = 3%)')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _fee,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Fee (mojos)')),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _busy ? null : _mint,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_photo_alternate),
                    label: const Text('bulk_mint_nfts (auto-submit)'),
                  ),
                  const SizedBox(height: 16),
                  if (_result.isNotEmpty)
                    SelectableText(_result,
                        style: const TextStyle(fontFamily: 'monospace')),
                ]),
    );
  }
}
