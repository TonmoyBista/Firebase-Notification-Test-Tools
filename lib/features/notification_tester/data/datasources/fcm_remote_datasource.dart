import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/service_account_entity.dart';
import '../models/fcm_response_model.dart';

abstract class IFcmRemoteDataSource {
  Future<AuthTokenEntity> getAccessToken(ServiceAccountEntity serviceAccount);

  Future<FcmResponseModel> sendFcmMessage({
    required String projectId,
    required String accessToken,
    required String payloadJson,
  });
}

class FcmRemoteDataSourceImpl implements IFcmRemoteDataSource {
  final http.Client httpClient;

  FcmRemoteDataSourceImpl({http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<AuthTokenEntity> getAccessToken(ServiceAccountEntity serviceAccount) async {
    try {
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccount.rawJson);

      final scopes = [AppConstants.fcmScope];
      final authClient =
          await clientViaServiceAccount(accountCredentials, scopes);

      final tokenData = authClient.credentials.accessToken.data;
      final expiry = authClient.credentials.accessToken.expiry;

      authClient.close();

      if (tokenData.isEmpty) {
        throw AuthException(message: 'Failed to retrieve access token: empty token returned');
      }

      return AuthTokenEntity(
        accessToken: tokenData,
        type: 'Bearer',
        expiry: expiry,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Authentication error: $e');
    }
  }

  @override
  Future<FcmResponseModel> sendFcmMessage({
    required String projectId,
    required String accessToken,
    required String payloadJson,
  }) async {
    final endpoint = AppConstants.getFcmSendUrl(projectId);
    final uri = Uri.parse(endpoint);

    final stopwatch = Stopwatch()..start();

    try {
      final response = await httpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; UTF-8',
        },
        body: utf8.encode(payloadJson),
      );

      stopwatch.stop();

      return FcmResponseModel.fromHttpResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        latencyMs: stopwatch.elapsedMilliseconds,
        requestUrl: endpoint,
        requestPayload: payloadJson,
      );
    } catch (e) {
      stopwatch.stop();
      if (e is http.ClientException) {
        throw ServerException(
          message: 'Network error: ${e.message}',
          statusCode: null,
          responseBody: e.toString(),
        );
      }
      throw ServerException(
        message: 'Request failed: $e',
        statusCode: null,
        responseBody: e.toString(),
      );
    }
  }
}
