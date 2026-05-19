// Tangem (external-signer / "arbor"): import a watch-only wallet from ONLY
// the card's BLS public key. Browsing (balance/tokens/NFTs/activity) uses the
// normal tabbed WalletScreen — those endpoints are read-only and work for a
// watch-only wallet. Only *spending* differs: there is no private key, so
// spends are built UNSIGNED and the exact AGG_SIG messages the card must sign
// over NFC are surfaced (required_signatures → submit_with_signatures).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';
import 'wallet_screen.dart';

class TangemImportScreen extends StatefulWidget {
  const TangemImportScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  State<TangemImportScreen> createState() => _TangemImportScreenState();
}

class _TangemImportScreenState extends State<TangemImportScreen> {
  final _name = TextEditingController(text: 'Tangem');
  final _pubkey = TextEditingController(text: kTangemDemoPublicKey);
  bool _busy = false;
  String _error = '';

  Future<void> _import() async {
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final res = await widget.sage.api.importKey(ImportKey(
        name: _name.text.trim().isEmpty ? 'Tangem' : _name.text.trim(),
        key: _pubkey.text.trim(),
        arborOnly: true, // only the public key; 1 puzzle, 0 derivations
        login: true,
      ));
      final k = (await widget.sage.api
              .getKey(GetKey(fingerprint: res.fingerprint)))
          .key;
      if (!mounted || k == null) return;
      // Same tabbed shell as a normal wallet (browse Tokens/NFTs/Activity);
      // WalletScreen detects arborOnly and swaps in the Tangem Send tab.
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => WalletScreen(sage: widget.sage, keyInfo: k)));
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Tangem card')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text(
            'A Tangem card only exposes its BLS public key. Sage imports it '
            'as an external-signer wallet: exactly one p2_delegated_conditions '
            '("arbor") puzzle, no HD derivations, no secret stored. '
            'Transactions are built unsigned; you sign the hashes on the card '
            'over NFC, then submit_with_signatures aggregates + broadcasts.'),
        const SizedBox(height: 16),
        TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Wallet name')),
        const SizedBox(height: 12),
        TextField(
            controller: _pubkey,
            maxLines: 2,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: const InputDecoration(
                labelText: 'Card BLS public key (48-byte hex)')),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _import,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.nfc),
          label: const Text('Import (watch-only · arbor)'),
        ),
        const SizedBox(height: 16),
        if (_error.isNotEmpty)
          SelectableText(_error,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
    );
  }
}

/// The "Send" tab for an arbor/Tangem wallet: no private key exists, so spends
/// are built UNSIGNED and `required_signatures` lists the exact messages the
/// card signs over NFC. Used by WalletScreen in place of SendXchTab.
class TangemSendTab extends StatefulWidget {
  const TangemSendTab({super.key, required this.sage, required this.keyInfo});
  final SageClient sage;
  final KeyInfo keyInfo;
  @override
  State<TangemSendTab> createState() => _TangemSendTabState();
}

class _TangemSendTabState extends State<TangemSendTab> {
  SageApi get _api => widget.sage.api;

  List<TokenRecord> _cats = [];
  List<NftRecord> _nfts = [];
  String _mode = 'xch'; // 'xch' | 'cat:<assetId>' | 'nft:<launcherId>'
  final _dest = TextEditingController();
  final _amount = TextEditingController(text: '0');
  bool _busy = false;
  String _out = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _api.getSyncStatus();
      final cats = (await _api.getCats()).cats;
      final nfts = (await _api.getNfts(GetNfts(
              offset: 0,
              limit: 100,
              includeHidden: true,
              sortMode: NftSortMode.recent)))
          .nfts;
      if (mounted) {
        setState(() {
          _cats = cats;
          _nfts = nfts;
          if (_dest.text.isEmpty) _dest.text = s.receiveAddress;
        });
      }
    } catch (_) {}
  }

  TokenRecord? get _selectedCat {
    if (!_mode.startsWith('cat:')) return null;
    final id = _mode.substring(4);
    for (final c in _cats) {
      if (c.assetId == id) return c;
    }
    return null;
  }

  Future<void> _build() async {
    setState(() {
      _busy = true;
      _out = '';
    });
    try {
      final dest = _dest.text.trim();
      TransactionResponse tx;
      if (_mode == 'xch') {
        tx = await _api.sendXch(SendXch(
          address: dest,
          amount: parseAmount(_amount.text, kXchPrecision),
          fee: BigInt.zero,
          autoSubmit: false, // build UNSIGNED — no secret key exists
        ));
      } else if (_mode.startsWith('cat:')) {
        final cat = _selectedCat!;
        tx = await _api.sendCat(SendCat(
          assetId: cat.assetId!,
          address: dest,
          amount: parseAmount(_amount.text, cat.precision),
          fee: BigInt.zero,
          autoSubmit: false,
        ));
      } else {
        final launcher = _mode.substring(4);
        tx = await _api.transferNfts(TransferNfts(
          nftIds: [launcher],
          address: dest,
          fee: BigInt.zero,
          autoSubmit: false,
        ));
      }

      final req = await _api.requiredSignatures(
          RequiredSignatures(coinSpends: tx.coinSpends));

      final card = widget.keyInfo.publicKey.replaceFirst('0x', '');
      final b = StringBuffer()
        ..writeln('coin spends : ${tx.coinSpends.length}')
        ..writeln('fee         : ${tx.summary.fee}')
        ..writeln('signatures  : ${req.signatures.length}')
        ..writeln('')
        ..writeln('// Send each "message" to the Tangem card (sign_hashes '
            'over NFC), collect the BLS signatures, then call '
            'submit_with_signatures(coinSpends, signatures, autoSubmit:true).')
        ..writeln('');
      for (var i = 0; i < req.signatures.length; i++) {
        final s = req.signatures[i];
        final ok = s.publicKey.replaceFirst('0x', '') == card;
        b
          ..writeln('sig[$i] pubkey : ${s.publicKey} '
              '${ok ? '✓ card key' : '✗ NOT card key'}')
          ..writeln('sig[$i] message: ${s.message}')
          ..writeln('');
      }
      setState(() => _out = b.toString());
    } catch (e) {
      setState(() => _out = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = <DropdownMenuEntry<String>>[
      const DropdownMenuEntry(value: 'xch', label: 'XCH'),
      for (final c in _cats)
        if (c.assetId != null)
          DropdownMenuEntry(
              value: 'cat:${c.assetId}',
              label:
                  'CAT ${c.ticker ?? c.name ?? c.assetId!.substring(0, 8)} '
                  '(${fmt(c.balance, c.precision)})'),
      for (final n in _nfts)
        DropdownMenuEntry(
            value: 'nft:${n.launcherId}',
            label: 'NFT ${n.name ?? n.launcherId.substring(0, 12)}'),
    ];
    final isNft = _mode.startsWith('nft:');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('External signer · single arbor puzzle',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      'No private key on this device. Sage builds the spend '
                      'and returns the exact AGG_SIG messages the card signs '
                      'over NFC.',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
          ),
        ),
        const SizedBox(height: 16),
        DropdownMenu<String>(
          initialSelection: _mode,
          expandedInsets: EdgeInsets.zero,
          label: const Text('Asset'),
          dropdownMenuEntries: entries,
          onSelected: (v) => setState(() => _mode = v ?? 'xch'),
        ),
        const SizedBox(height: 12),
        TextField(
            controller: _dest,
            decoration: const InputDecoration(
                labelText: 'Destination (defaults to self)')),
        if (!isNft) ...[
          const SizedBox(height: 12),
          TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount')),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _build,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.fingerprint),
          label: const Text('Build unsigned → required_signatures'),
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
