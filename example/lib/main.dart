// Reference wallet for the sage_flutter_binding — a near-complete Chia wallet
// mirroring Sage's Tauri UI, screen by screen, on top of the typed Dart API.
//
// Structure (see src/screens/):
//   • Wallets / auth ............ keys_screen.dart
//   • Active wallet shell ....... wallet_screen.dart  (5 bottom tabs)
//       - Overview .............. overview_tab.dart
//       - Tokens (+CAT detail) .. tokens_tab.dart
//       - Send XCH .............. send_xch_tab.dart
//       - Activity (+TX detail) . activity_tab.dart
//       - More hub .............. more_tab.dart
//   • Receive (QR) .............. receive_screen.dart
//   • Offers / DEX .............. offers_screen.dart  (make / view / take)
//   • Issue CAT ................. issue_cat_screen.dart
//   • Mint NFT .................. mint_nft_screen.dart
//   • Addresses / NFTs / DIDs ... addresses|nfts|dids_screen.dart
//   • Network & Peers ........... network_screen.dart
//   • Settings (switch network) . settings_screen.dart
//   • WalletConnect endpoints ... walletconnect_screen.dart
//   • API Console (all 105) ..... console_screen.dart
//   • Tangem external signer .... tangem_screen.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import 'src/screens/keys_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SageBinding.init();
  runApp(const SageDemoApp());
}

class SageDemoApp extends StatelessWidget {
  const SageDemoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sage Wallet (demo)',
        theme: ThemeData(
            colorSchemeSeed: const Color(0xFF5C4B9A), useMaterial3: true),
        home: const BootGate(),
      );
}

/// Boots a single Sage instance rooted in the app-private support dir, then
/// hands off to the wallets screen. Everything else navigates from there.
class BootGate extends StatefulWidget {
  const BootGate({super.key});
  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  SageClient? _sage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');
      setState(() => _sage = sage);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Sage failed:\n$_error')));
    }
    if (_sage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return KeysScreen(sage: _sage!);
  }
}
