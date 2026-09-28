class FcmResponseEntity {
  final int statusCode;
  final bool isSuccess;
  final String rawBody;
  final Map<String, String> headers;
  final DateTime timestamp;
  final int latencyMs;
  final String? messageId;
  final String? errorMessage;
  final String requestUrl;
  final String requestPayload;

  const FcmResponseEntity({
    required this.statusCode,
    required this.isSuccess,
    required this.rawBody,
    required this.headers,
    required this.timestamp,
    required this.latencyMs,
    this.messageId,
    this.errorMessage,
    required this.requestUrl,
    required this.requestPayload,
  });
}
