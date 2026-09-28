import 'dart:convert';

class JsonUtils {
  static final JsonEncoder _prettyEncoder = const JsonEncoder.withIndent('  ');

  static String prettify(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      return _prettyEncoder.convert(decoded);
    } catch (_) {
      return rawJson;
    }
  }

  static String formatMap(Map<String, dynamic> map) {
    try {
      return _prettyEncoder.convert(map);
    } catch (_) {
      return jsonEncode(map);
    }
  }

  static bool isValid(String rawJson) {
    try {
      jsonDecode(rawJson);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic>? tryParse(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String generateCurl({
    required String url,
    required String accessToken,
    required String bodyJson,
  }) {
    final escapedJson = bodyJson.replaceAll("'", "'\\''");
    return '''curl -X POST "$url" \\
  -H "Authorization: Bearer $accessToken" \\
  -H "Content-Type: application/json; UTF-8" \\
  -d '$escapedJson' ''';
  }
}
