/// Flutter binding for the [Sage](https://github.com/xch-dev/sage) Chia wallet.
///
/// Sage's wallet core is linked in-process (no RPC server, no TLS sockets).
/// Use the typed [SageApi] facade via `SageClient.api`:
///
/// ```dart
/// import 'package:path_provider/path_provider.dart';
/// import 'package:sage_flutter_binding/sage_flutter_binding.dart';
///
/// await SageBinding.init();
/// final dir = await getApplicationSupportDirectory();
/// final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');
///
/// final res = await sage.api.generateMnemonic(
///   GenerateMnemonic(use24Words: true),
/// );
/// print(res.mnemonic);
/// ```
///
/// For endpoints not yet typed (or to bypass the models) use the raw
/// [SageClientJson.callJson] escape hatch.
library;

import 'src/rust/api/sage_client.dart';
import 'src/rust/frb_generated.dart';
import 'src/sage_api.g.dart';

export 'src/rust/api/sage_client.dart' show SageClient;
export 'src/sage_client_ext.dart' show SageClientJson;
export 'src/sage_api.g.dart';

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

/// Entry point to the typed API: `client.api.login(...)`, etc.
extension SageApiAccess on SageClient {
  SageApi get api => SageApi(this);
}
