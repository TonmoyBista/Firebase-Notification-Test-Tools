class HistoryItemEntity {
  final String id;
  final DateTime timestamp;
  final String projectId;
  final String target;
  final String title;
  final String body;
  final String payloadJson;
  final int statusCode;
  final String responseBody;
  final int latencyMs;
  final bool isSuccess;

  const HistoryItemEntity({
    required this.id,
    required this.timestamp,
    required this.projectId,
    required this.target,
    required this.title,
    required this.body,
    required this.payloadJson,
    required this.statusCode,
    required this.responseBody,
    required this.latencyMs,
    required this.isSuccess,
  });
}
