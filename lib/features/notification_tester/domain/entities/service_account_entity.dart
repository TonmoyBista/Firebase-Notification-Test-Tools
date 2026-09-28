class ServiceAccountEntity {
  final String type;
  final String projectId;
  final String privateKeyId;
  final String privateKey;
  final String clientEmail;
  final String clientId;
  final String rawJson;

  const ServiceAccountEntity({
    required this.type,
    required this.projectId,
    required this.privateKeyId,
    required this.privateKey,
    required this.clientEmail,
    required this.clientId,
    required this.rawJson,
  });

  bool get isValid =>
      type == 'service_account' &&
      projectId.isNotEmpty &&
      privateKey.isNotEmpty &&
      clientEmail.isNotEmpty;
}
