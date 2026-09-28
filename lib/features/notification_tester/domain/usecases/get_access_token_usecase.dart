import '../entities/auth_token_entity.dart';
import '../entities/service_account_entity.dart';
import '../repositories/fcm_repository.dart';

class GetAccessTokenUseCase {
  final IFcmRepository repository;

  GetAccessTokenUseCase(this.repository);

  Future<AuthTokenEntity> execute(ServiceAccountEntity serviceAccount) async {
    return await repository.getAccessToken(serviceAccount);
  }
}
