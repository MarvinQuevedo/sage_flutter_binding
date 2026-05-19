// Wallets / auth — list keys, create (with recovery phrase), import, delete,
// open. Tangem (external-signer) wallets route to their own screen.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';
import 'tangem_screen.dart';
import 'wallet_screen.dart';

class KeysScreen extends StatefulWidget {
  const KeysScreen({super.key, required this.sage});
  final SageClient sage;
  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  SageApi get _api => widget.sage.api;
  List<KeyInfo> _keys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() =>
      _run(() async => _keys = (await _api.getKeys()).keys);

  Future<void> _createWallet() async {
    final name = await promptText(context, 'New wallet name',
        initial: 'My Wallet');
    if (name == null || name.isEmpty) return;
    await _run(() async {
      final m = await _api.generateMnemonic(GenerateMnemonic(use24Words: true));
      await _api.importKey(ImportKey(
          name: name, key: m.mnemonic, login: true, derivationIndex: 1000));
      if (mounted) {
        await showTextDialog(
            context, 'Save your recovery phrase', m.mnemonic);
      }
      _keys = (await _api.getKeys()).keys;
    });
  }

  Future<void> _importWallet() async {
    final name =
        await promptText(context, 'Wallet name', initial: 'Imported');
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    final phrase =
        await promptText(context, 'Mnemonic / private / public key');
    if (phrase == null || phrase.trim().isEmpty) return;
    await _run(() async {
      await _api.importKey(ImportKey(
          name: name,
          key: phrase.trim(),
          login: true,
          derivationIndex: 1000,
          hardened: true,
          unhardened: true));
      _keys = (await _api.getKeys()).keys;
    });
  }

  Future<void> _open(KeyInfo k) async {
    await _run(() => _api.login(Login(fingerprint: k.fingerprint)));
    if (!mounted) return;
    // Both normal and Tangem/arbor wallets use the same tabbed shell;
    // WalletScreen detects arborOnly (skips derivation growth, swaps in the
    // external-signer Send tab) so Tangem can still browse tokens/NFTs/etc.
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WalletScreen(sage: widget.sage, keyInfo: k)));
    _refresh();
  }

  Future<void> _importTangem() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TangemImportScreen(sage: widget.sage)));
    _refresh();
  }

  Future<void> _delete(KeyInfo k) async {
    if (!await confirm(context, 'Delete "${k.name}"?',
        confirmLabel: 'Delete')) {
      return;
    }
    await _run(() async {
      await _api.deleteKey(DeleteKey(fingerprint: k.fingerprint));
      _keys = (await _api.getKeys()).keys;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sage Wallets'), actions: [
        IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh)),
      ]),
      body: Column(children: [
        if (_error != null)
          Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(_error!)),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: _keys.isEmpty && !_loading
              ? const Center(child: Text('No wallets yet — create one.'))
              : ListView(children: [
                  for (final k in _keys)
                    ListTile(
                      leading: Text(k.emoji ?? '🔑',
                          style: const TextStyle(fontSize: 24)),
                      title: Text(k.name),
                      subtitle: Text(
                          'fp ${k.fingerprint} · ${k.kind.value} · ${k.networkId}'),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(k)),
                      onTap: () => _open(k),
                    ),
                ]),
        ),
      ]),
      floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
                heroTag: 'tangem',
                onPressed: _loading ? null : _importTangem,
                icon: const Icon(Icons.nfc),
                label: const Text('Tangem')),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
                heroTag: 'imp',
                onPressed: _loading ? null : _importWallet,
                icon: const Icon(Icons.download),
                label: const Text('Import')),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
                heroTag: 'new',
                onPressed: _loading ? null : _createWallet,
                icon: const Icon(Icons.add),
                label: const Text('New')),
          ]),
    );
  }
}
