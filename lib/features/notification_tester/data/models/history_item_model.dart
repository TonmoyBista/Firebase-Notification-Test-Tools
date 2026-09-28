import 'dart:convert';
import '../../domain/entities/history_item_entity.dart';

class HistoryItemModel extends HistoryItemEntity {
  const HistoryItemModel({
    required super.id,
    required super.timestamp,
    required super.projectId,
    required super.target,
    required super.title,
    required super.body,
    required super.payloadJson,
    required super.statusCode,
    required super.responseBody,
    required super.latencyMs,
    required super.isSuccess,
  });

  factory HistoryItemModel.fromEntity(HistoryItemEntity entity) {
    return HistoryItemModel(
      id: entity.id,
      timestamp: entity.timestamp,
      projectId: entity.projectId,
      target: entity.target,
      title: entity.title,
      body: entity.body,
      payloadJson: entity.payloadJson,
      statusCode: entity.statusCode,
      responseBody: entity.responseBody,
      latencyMs: entity.latencyMs,
      isSuccess: entity.isSuccess,
    );
  }

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      projectId: json['projectId']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      payloadJson: json['payloadJson']?.toString() ?? '',
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      responseBody: json['responseBody']?.toString() ?? '',
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      isSuccess: json['isSuccess'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'projectId': projectId,
      'target': target,
      'title': title,
      'body': body,
      'payloadJson': payloadJson,
      'statusCode': statusCode,
      'responseBody': responseBody,
      'latencyMs': latencyMs,
      'isSuccess': isSuccess,
    };
  }

  static String encodeList(List<HistoryItemEntity> list) {
    return jsonEncode(list.map((e) => HistoryItemModel.fromEntity(e).toJson()).toList());
  }

  static List<HistoryItemEntity> decodeList(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .map((item) => HistoryItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
