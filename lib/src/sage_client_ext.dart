import 'dart:convert';

import 'rust/api/sage_client.dart';

/// JSON convenience helpers on top of the generated string-based [SageClient].
///
/// This is the low-level escape hatch. Prefer the typed `SageClient.api`
/// facade (see `sage_api.g.dart`) for day-to-day use.
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
