// Offers / DEX — the core differentiator of a Chia wallet:
//   • list saved offers (+ cancel, + copy the offer string)
//   • make a new offer (offered vs requested assets) → make_offer
//   • paste an offer string → view_offer (preview) → take_offer (accept)
//   • import an offer string into the wallet's offer list
//
// Asset inputs accept a CAT/NFT asset id or are left blank for XCH. Amounts
// are entered in the smallest unit (mojos for XCH) to keep the demo simple.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

String _assetLabel(Asset a) =>
    a.ticker ?? a.name ?? (a.assetId == null ? 'XCH' : a.kind.value);

Widget _offerSide(BuildContext ctx, String title, List<OfferAsset> assets) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(ctx).textTheme.titleSmall),
      if (assets.isEmpty) const Text('  (nothing)'),
      for (final a in assets)
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 2),
          child: Text(
              '• ${fmt(a.amount, a.asset.precision)} ${_assetLabel(a.asset)}'
              '${a.royalty > BigInt.zero ? '  (royalty ${fmt(a.royalty, a.asset.precision)})' : ''}'),
        ),
    ]);

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key, required this.api});
  final SageApi api;

  @override
  Widget build(BuildContext context) {
    final viewKey = GlobalKey<ApiViewState<List<OfferRecord>>>();
    return Scaffold(
      appBar: AppBar(title: const Text('Offers / DEX'), actions: [
        IconButton(
          tooltip: 'Import / take offer',
          icon: const Icon(Icons.input),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (_) => ViewOfferScreen(api: api)))
              .then((_) => viewKey.currentState?.refresh()),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(
                MaterialPageRoute(builder: (_) => MakeOfferScreen(api: api)))
            .then((_) => viewKey.currentState?.refresh()),
        icon: const Icon(Icons.add),
        label: const Text('Make offer'),
      ),
      body: ApiView<List<OfferRecord>>(
        key: viewKey,
        load: () async => (await api.getOffers(GetOffers())).offers,
        builder: (ctx, offers, refresh) => offers.isEmpty
            ? ListView(children: const [
                SizedBox(height: 180),
                Center(child: Text('No saved offers.')),
              ])
            : ListView(children: [
                for (final o in offers)
                  ExpansionTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text('${o.status.value} · fee ${o.summary.fee}'),
                    subtitle: Text(o.offerId,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [
                      _offerSide(ctx, 'Offering (maker)', o.summary.maker),
                      const SizedBox(height: 8),
                      _offerSide(ctx, 'Requesting (taker)', o.summary.taker),
                      const SizedBox(height: 12),
                      Row(children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: o.offer));
                            if (ctx.mounted) toast(ctx, 'Offer copied');
                          },
                        ),
                        const SizedBox(width: 8),
                        if (o.status == OfferRecordStatus.active ||
                            o.status == OfferRecordStatus.pending)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text('Cancel'),
                            onPressed: () async {
                              if (!await confirm(ctx, 'Cancel this offer?',
                                  confirmLabel: 'Cancel offer')) {
                                return;
                              }
                              try {
                                await api.cancelOffer(CancelOffer(
                                    offerId: o.offerId,
                                    fee: BigInt.zero,
                                    autoSubmit: true));
                                if (ctx.mounted) toast(ctx, 'Cancel submitted');
                                await refresh();
                              } catch (e) {
                                if (ctx.mounted) toast(ctx, '$e');
                              }
                            },
                          ),
                      ]),
                    ],
                  ),
              ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Make offer
// ---------------------------------------------------------------------------
class MakeOfferScreen extends StatefulWidget {
  const MakeOfferScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  final _offerAsset = TextEditingController();
  final _offerAmount = TextEditingController(text: '0');
  final _reqAsset = TextEditingController();
  final _reqAmount = TextEditingController(text: '0');
  final _fee = TextEditingController(text: '0');
  bool _busy = false;
  String _result = '';

  OfferAmount _amount(TextEditingController asset, TextEditingController amt) {
    final id = asset.text.trim();
    return OfferAmount(
      amount: mojos(amt.text),
      assetId: id.isEmpty ? null : id,
    );
  }

  Future<void> _make() async {
    setState(() {
      _busy = true;
      _result = '';
    });
    try {
      final res = await widget.api.makeOffer(MakeOffer(
        offeredAssets: [_amount(_offerAsset, _offerAmount)],
        requestedAssets: [_amount(_reqAsset, _reqAmount)],
        fee: mojos(_fee.text),
        autoImport: true,
      ));
      setState(() => _result =
          'offer_id: ${res.offerId}\n\n${res.offer}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make offer')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Leave an asset id blank for XCH. Amounts are in the '
            'smallest unit (mojos for XCH).'),
        const SizedBox(height: 16),
        Text('You offer', style: Theme.of(context).textTheme.titleMedium),
        TextField(
            controller: _offerAsset,
            decoration: const InputDecoration(
                labelText: 'Offered asset id (blank = XCH)')),
        const SizedBox(height: 8),
        TextField(
            controller: _offerAmount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Offered amount')),
        const Divider(height: 32),
        Text('You request', style: Theme.of(context).textTheme.titleMedium),
        TextField(
            controller: _reqAsset,
            decoration: const InputDecoration(
                labelText: 'Requested asset id (blank = XCH)')),
        const SizedBox(height: 8),
        TextField(
            controller: _reqAmount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Requested amount')),
        const SizedBox(height: 12),
        TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fee (mojos)')),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _make,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.handshake),
          label: const Text('make_offer (auto-import)'),
        ),
        const SizedBox(height: 16),
        if (_result.isNotEmpty) ...[
          Row(children: [
            const Expanded(child: Text('Offer string')),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => Clipboard.setData(
                  ClipboardData(text: _result.split('\n\n').last)),
            ),
          ]),
          SelectableText(_result,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// View / take / import an offer string
// ---------------------------------------------------------------------------
class ViewOfferScreen extends StatefulWidget {
  const ViewOfferScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<ViewOfferScreen> createState() => _ViewOfferScreenState();
}

class _ViewOfferScreenState extends State<ViewOfferScreen> {
  final _offer = TextEditingController();
  final _fee = TextEditingController(text: '0');
  ViewOfferResponse? _preview;
  bool _busy = false;
  String _status = '';

  Future<void> _view() async {
    setState(() {
      _busy = true;
      _status = '';
      _preview = null;
    });
    try {
      final r =
          await widget.api.viewOffer(ViewOffer(offer: _offer.text.trim()));
      setState(() => _preview = r);
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _take() async {
    setState(() {
      _busy = true;
      _status = '';
    });
    try {
      final r = await widget.api.takeOffer(TakeOffer(
        offer: _offer.text.trim(),
        fee: mojos(_fee.text),
        autoSubmit: true,
      ));
      setState(() => _status = 'Accepted ✓  tx: ${r.transactionId}');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    try {
      await widget.api.importOffer(ImportOffer(offer: _offer.text.trim()));
      if (mounted) toast(context, 'Offer imported');
    } catch (e) {
      if (mounted) toast(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _preview;
    return Scaffold(
      appBar: AppBar(title: const Text('View / take offer')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          controller: _offer,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: const InputDecoration(
              labelText: 'Paste offer string', filled: true),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _view,
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.download),
              label: const Text('Import'),
            ),
          ),
        ]),
        if (p != null) ...[
          const Divider(height: 28),
          Text('Status: ${p.status.value}',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _offerSide(context, 'You receive (maker gives)', p.offer.maker),
          const SizedBox(height: 8),
          _offerSide(context, 'You give (taker gives)', p.offer.taker),
          const SizedBox(height: 8),
          kv('Offer fee', '${p.offer.fee}'),
          const Divider(height: 28),
          TextField(
              controller: _fee,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Your fee (mojos)')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _take,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('take_offer (auto-submit)'),
          ),
        ],
        const SizedBox(height: 16),
        if (_status.isNotEmpty)
          SelectableText(_status,
              style: const TextStyle(fontFamily: 'monospace')),
      ]),
    );
  }
}
