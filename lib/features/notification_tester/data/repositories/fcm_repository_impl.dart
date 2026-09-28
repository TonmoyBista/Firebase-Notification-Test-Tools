import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/fcm_response_entity.dart';
import '../../domain/entities/service_account_entity.dart';
import '../../domain/repositories/fcm_repository.dart';
import '../datasources/fcm_remote_datasource.dart';

class FcmRepositoryImpl implements IFcmRepository {
  final IFcmRemoteDataSource remoteDataSource;

  FcmRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthTokenEntity> getAccessToken(ServiceAccountEntity serviceAccount) async {
    try {
      return await remoteDataSource.getAccessToken(serviceAccount);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<FcmResponseEntity> sendMessage({
    required String projectId,
    required String accessToken,
    required String messagePayloadJson,
  }) async {
    try {
      return await remoteDataSource.sendFcmMessage(
        projectId: projectId,
        accessToken: accessToken,
        payloadJson: messagePayloadJson,
      );
    } on ServerException catch (e) {
      throw ServerFailure(
        e.message,
        statusCode: e.statusCode,
        rawResponse: e.responseBody,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
