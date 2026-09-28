import '../../domain/entities/service_account_entity.dart';

class ServiceAccountModel extends ServiceAccountEntity {
  const ServiceAccountModel({
    required super.type,
    required super.projectId,
    required super.privateKeyId,
    required super.privateKey,
    required super.clientEmail,
    required super.clientId,
    required super.rawJson,
  });

  factory ServiceAccountModel.fromJson(Map<String, dynamic> json, String rawJson) {
    return ServiceAccountModel(
      type: json['type']?.toString() ?? 'service_account',
      projectId: json['project_id']?.toString() ?? '',
      privateKeyId: json['private_key_id']?.toString() ?? '',
      privateKey: json['private_key']?.toString() ?? '',
      clientEmail: json['client_email']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      rawJson: rawJson,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'project_id': projectId,
      'private_key_id': privateKeyId,
      'private_key': privateKey,
      'client_email': clientEmail,
      'client_id': clientId,
    };
  }
}
