// "More" hub: every secondary screen of the wallet, grouped.
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import 'addresses_screen.dart';
import 'console_screen.dart';
import 'dids_screen.dart';
import 'issue_cat_screen.dart';
import 'mint_nft_screen.dart';
import 'network_screen.dart';
import 'nfts_screen.dart';
import 'offers_screen.dart';
import 'settings_screen.dart';
import 'walletconnect_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key, required this.sage, required this.keyInfo});
  final SageClient sage;
  final KeyInfo keyInfo;
  @override
  Widget build(BuildContext context) {
    void go(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    final api = sage.api;
    final items = <(IconData, String, VoidCallback)>[
      (Icons.swap_horiz, 'Offers / DEX', () => go(OffersScreen(api: api))),
      (Icons.toll, 'Issue CAT token', () => go(IssueCatScreen(api: api))),
      (Icons.image, 'NFTs', () => go(NftsScreen(api: api))),
      (Icons.add_photo_alternate, 'Mint NFT',
          () => go(MintNftScreen(api: api))),
      (Icons.badge, 'DIDs / Profiles', () => go(DidsScreen(api: api))),
      (Icons.account_tree, 'Addresses', () => go(AddressesScreen(api: api))),
      (Icons.lan, 'Network & Peers', () => go(NetworkScreen(sage: sage))),
      (Icons.settings, 'Settings (network)',
          () => go(SettingsScreen(sage: sage))),
      (Icons.link, 'WalletConnect', () => go(WalletConnectScreen(sage: sage))),
      (Icons.terminal, 'API Console', () => go(ConsoleScreen(client: sage))),
    ];
    return ListView(children: [
      for (final (icon, label, onTap) in items)
        ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
    ]);
  }
}
