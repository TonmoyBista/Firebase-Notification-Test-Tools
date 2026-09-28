import '../entities/auth_token_entity.dart';
import '../entities/fcm_response_entity.dart';
import '../entities/service_account_entity.dart';

abstract class IFcmRepository {
  Future<AuthTokenEntity> getAccessToken(ServiceAccountEntity serviceAccount);

  Future<FcmResponseEntity> sendMessage({
    required String projectId,
    required String accessToken,
    required String messagePayloadJson,
  });
}
