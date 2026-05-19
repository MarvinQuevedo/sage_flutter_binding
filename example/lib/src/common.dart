// Shared helpers used across every screen of the reference wallet.
//
// Kept deliberately tiny: amount <-> mojo conversion, a key/value row, the
// generic "load → loading/error/result" body (ApiView) and a couple of
// dialog helpers. Screens live under src/screens/.
import 'package:flutter/material.dart';

/// XCH has 12 decimals (mojos). CATs carry their own precision (usually 3).
const int kXchPrecision = 12;

/// Demo Tangem card BLS public key (the one used in the Rust tests). Replace
/// with the public key your real Tangem card exposes over NFC.
const String kTangemDemoPublicKey =
    '0x8fba5482e6c798a06ee1fd95deaaa83f11c46da06006ab3524e917f4e116c2bdec69d6098043ca568290ac366e5e2dc5';

/// Render a base-10 fixed-point amount (e.g. mojos → "1.5").
String fmt(BigInt v, int precision) {
  final d = BigInt.from(10).pow(precision);
  final w = v ~/ d;
  final f = (v % d)
      .toString()
      .padLeft(precision, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return f.isEmpty ? '$w' : '$w.$f';
}

/// Parse a user-typed decimal ("1.5") into the smallest unit for `precision`.
BigInt parseAmount(String s, int precision) {
  final parts = s.trim().split('.');
  final whole = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
  var frac = parts.length > 1 ? parts[1] : '';
  frac = frac.padRight(precision, '0').substring(0, precision);
  return whole * BigInt.from(10).pow(precision) +
      (frac.isEmpty ? BigInt.zero : BigInt.parse(frac));
}

/// Parse a raw mojo integer string (fees are always entered in mojos).
BigInt mojos(String s) => BigInt.parse(s.trim().isEmpty ? '0' : s.trim());

/// A label/value row used in every detail card.
Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: const TextStyle(color: Colors.black54)),
        Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );

/// Generic "run an async API call, show loading/error/result" scaffold body
/// with pull-to-refresh.
class ApiView<T> extends StatefulWidget {
  const ApiView({super.key, required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T, Future<void> Function()) builder;
  @override
  State<ApiView<T>> createState() => ApiViewState<T>();
}

class ApiViewState<T> extends State<ApiView<T>> {
  T? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final d = await widget.load();
      if (mounted) {
        setState(() {
          _data = d;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ]),
      );
    }
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: widget.builder(context, _data as T, refresh),
    );
  }
}

/// Single-field text prompt dialog. Returns null on cancel.
Future<String?> promptText(BuildContext context, String title,
    {String initial = '', String? hint}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (x) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        decoration: hint == null ? null : InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(x), child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(x, c.text),
            child: const Text('OK')),
      ],
    ),
  );
}

/// Read-only, copyable text dialog (recovery phrases, signatures, …).
Future<void> showTextDialog(
        BuildContext context, String title, String body) =>
    showDialog<void>(
      context: context,
      builder: (x) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(body,
              style: const TextStyle(fontFamily: 'monospace', height: 1.5)),
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(x), child: const Text('Done')),
        ],
      ),
    );

/// Yes/No confirmation dialog. Returns true only if confirmed.
Future<bool> confirm(BuildContext context, String title,
    {String body = '', String confirmLabel = 'Confirm'}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (x) => AlertDialog(
      title: Text(title),
      content: body.isEmpty ? null : Text(body),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(x, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(x, true),
            child: Text(confirmLabel)),
      ],
    ),
  );
  return ok == true;
}

/// Show a transient SnackBar (no-op if the widget is gone).
void toast(BuildContext context, String msg) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
