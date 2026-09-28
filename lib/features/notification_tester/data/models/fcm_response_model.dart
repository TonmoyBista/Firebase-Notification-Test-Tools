import 'dart:convert';
import '../../domain/entities/fcm_response_entity.dart';

class FcmResponseModel extends FcmResponseEntity {
  const FcmResponseModel({
    required super.statusCode,
    required super.isSuccess,
    required super.rawBody,
    required super.headers,
    required super.timestamp,
    required super.latencyMs,
    super.messageId,
    super.errorMessage,
    required super.requestUrl,
    required super.requestPayload,
  });

  factory FcmResponseModel.fromHttpResponse({
    required int statusCode,
    required String body,
    required Map<String, String> headers,
    required int latencyMs,
    required String requestUrl,
    required String requestPayload,
  }) {
    String? messageId;
    String? errorMessage;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('name')) {
          messageId = decoded['name']?.toString();
        }
        if (decoded.containsKey('error')) {
          final err = decoded['error'];
          if (err is Map<String, dynamic>) {
            errorMessage = err['message']?.toString() ?? err['status']?.toString();
          } else {
            errorMessage = err.toString();
          }
        }
      }
    } catch (_) {
      // Body might not be JSON, keep errorMessage null or status code text
    }

    if (!isSuccess && errorMessage == null) {
      errorMessage = 'HTTP Error $statusCode';
    }

    return FcmResponseModel(
      statusCode: statusCode,
      isSuccess: isSuccess,
      rawBody: body,
      headers: headers,
      timestamp: DateTime.now(),
      latencyMs: latencyMs,
      messageId: messageId,
      errorMessage: errorMessage,
      requestUrl: requestUrl,
      requestPayload: requestPayload,
    );
  }
}
