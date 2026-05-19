/// Flutter binding for the [Sage](https://github.com/xch-dev/sage) Chia wallet.
///
/// Sage's wallet core is linked in-process (no RPC server, no TLS sockets).
/// Every endpoint Sage's RPC exposes is reachable through [SageClient.call]
/// with the exact same request/response JSON.
///
/// ```dart
/// import 'package:path_provider/path_provider.dart';
/// import 'package:sage_flutter_binding/sage_flutter_binding.dart';
///
/// await SageBinding.init();
/// final dir = await getApplicationSupportDirectory();
/// final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');
///
/// final mnemonic =
///     await sage.callJson('generate_mnemonic', {'use_24_words': true});
/// ```
library;

import 'dart:convert';

import 'src/rust/api/sage_client.dart';
import 'src/rust/frb_generated.dart';

export 'src/rust/api/sage_client.dart' show SageClient;

/// One-time loader for the native Sage library. Call before any [SageClient].
class SageBinding {
  SageBinding._();

  static bool _initialized = false;

  /// Loads the bundled native library and initializes flutter_rust_bridge.
  /// Safe to call multiple times.
  static Future<void> init() async {
    if (_initialized) return;
    await RustLib.init();
    _initialized = true;
  }

  /// Releases the native library (mainly useful in tests).
  static Future<void> dispose() async {
    if (!_initialized) return;
    RustLib.dispose();
    _initialized = false;
  }
}

/// JSON convenience helpers on top of the generated string-based [SageClient].
extension SageClientJson on SageClient {
  /// Calls [endpoint] with a Dart map body and decodes the JSON response.
  ///
  /// Throws if Sage returns an error (the message is the Rust error string).
  Future<Map<String, dynamic>> callJson(
    String endpoint, [
    Map<String, dynamic> request = const {},
  ]) async {
    final responseJson = await call(
      endpoint: endpoint,
      requestJson: jsonEncode(request),
    );
    final decoded = jsonDecode(responseJson);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'result': decoded};
  }
}
