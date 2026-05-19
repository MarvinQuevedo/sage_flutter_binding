// DIDs / profiles: list + create (create_did).
import 'package:flutter/material.dart';
import 'package:sage_flutter_binding/sage_flutter_binding.dart';

import '../common.dart';

class DidsScreen extends StatefulWidget {
  const DidsScreen({super.key, required this.api});
  final SageApi api;
  @override
  State<DidsScreen> createState() => _DidsScreenState();
}

class _DidsScreenState extends State<DidsScreen> {
  Future<void> _create() async {
    final name = await promptText(context, 'Create DID (profile)',
        initial: 'My Profile');
    if (name == null || name.isEmpty) return;
    try {
      await widget.api
          .createDid(CreateDid(name: name, fee: BigInt.zero, autoSubmit: true));
      if (mounted) toast(context, 'DID submitted');
    } catch (e) {
      if (mounted) toast(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DIDs / Profiles')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _create,
          icon: const Icon(Icons.add),
          label: const Text('Create DID')),
      body: ApiView<List<DidRecord>>(
        load: () async => (await widget.api.getDids()).dids,
        builder: (ctx, dids, refresh) => dids.isEmpty
            ? ListView(children: const [
                SizedBox(height: 180),
                Center(child: Text('No DIDs. Create one.')),
              ])
            : ListView(children: [
                for (final d in dids)
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(d.name ?? '(unnamed DID)'),
                    subtitle: Text(d.launcherId,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ]),
      ),
    );
  }
}
