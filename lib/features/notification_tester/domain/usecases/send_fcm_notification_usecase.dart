import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../entities/fcm_response_entity.dart';
import '../repositories/fcm_repository.dart';

class SendFcmNotificationUseCase {
  final IFcmRepository repository;

  SendFcmNotificationUseCase(this.repository);

  Future<FcmResponseEntity> execute({
    required String projectId,
    required String accessToken,
    required String messagePayloadJson,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ValidationException(message: 'Project ID cannot be empty');
    }
    if (accessToken.trim().isEmpty) {
      throw ValidationException(message: 'OAuth Access Token is missing or invalid');
    }
    if (messagePayloadJson.trim().isEmpty) {
      throw ValidationException(message: 'Message payload cannot be empty');
    }

    try {
      jsonDecode(messagePayloadJson);
    } on FormatException catch (e) {
      throw ValidationException(message: 'Invalid message JSON syntax: ${e.message}');
    }

    return await repository.sendMessage(
      projectId: projectId.trim(),
      accessToken: accessToken.trim(),
      messagePayloadJson: messagePayloadJson.trim(),
    );
  }
}
