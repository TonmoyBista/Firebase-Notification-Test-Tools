import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../entities/service_account_entity.dart';

class ParseServiceAccountUseCase {
  ServiceAccountEntity execute(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw ValidationException(message: 'JSON file is empty');
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException(message: 'Invalid JSON format: expected object');
      }

      final type = decoded['type']?.toString() ?? '';
      final projectId = decoded['project_id']?.toString() ?? '';
      final privateKeyId = decoded['private_key_id']?.toString() ?? '';
      final privateKey = decoded['private_key']?.toString() ?? '';
      final clientEmail = decoded['client_email']?.toString() ?? '';
      final clientId = decoded['client_id']?.toString() ?? '';

      if (projectId.isEmpty) {
        throw ValidationException(message: 'Missing "project_id" in Service Account JSON');
      }
      if (privateKey.isEmpty) {
        throw ValidationException(message: 'Missing "private_key" in Service Account JSON');
      }
      if (clientEmail.isEmpty) {
        throw ValidationException(message: 'Missing "client_email" in Service Account JSON');
      }

      return ServiceAccountEntity(
        type: type.isNotEmpty ? type : 'service_account',
        projectId: projectId,
        privateKeyId: privateKeyId,
        privateKey: privateKey,
        clientEmail: clientEmail,
        clientId: clientId,
        rawJson: jsonString,
      );
    } on FormatException catch (e) {
      throw ValidationException(message: 'Invalid JSON syntax: ${e.message}');
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException(message: 'Failed to parse Service Account: $e');
    }
  }
}
