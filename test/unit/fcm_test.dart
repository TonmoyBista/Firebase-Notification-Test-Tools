import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_notification_test_tools/core/errors/exceptions.dart';
import 'package:firebase_notification_test_tools/core/utils/json_utils.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/data/models/fcm_response_model.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/data/models/history_item_model.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/fcm_message_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/history_item_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/usecases/parse_service_account_usecase.dart';

void main() {
  group('ParseServiceAccountUseCase Tests', () {
    final useCase = ParseServiceAccountUseCase();

    test('should parse valid service account JSON', () {
      const validJson = '''
      {
        "type": "service_account",
        "project_id": "test-project-123",
        "private_key_id": "key-id-abc",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvg...\\n-----END PRIVATE KEY-----\\n",
        "client_email": "firebase-adminsdk@test-project-123.iam.gserviceaccount.com",
        "client_id": "123456789"
      }
      ''';

      final entity = useCase.execute(validJson);

      expect(entity.projectId, 'test-project-123');
      expect(entity.clientEmail,
          'firebase-adminsdk@test-project-123.iam.gserviceaccount.com');
      expect(entity.type, 'service_account');
      expect(entity.isValid, isTrue);
    });

    test('should throw ValidationException when project_id is missing', () {
      const missingProjectJson = '''
      {
        "type": "service_account",
        "private_key": "some-key",
        "client_email": "some-email"
      }
      ''';

      expect(
        () => useCase.execute(missingProjectJson),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ValidationException on invalid JSON', () {
      expect(
        () => useCase.execute('invalid-json-text'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('FcmMessageEntity Tests', () {
    test('should build valid FCM v1 message structure for device token', () {
      const message = FcmMessageEntity(
        targetType: TargetType.token,
        targetValue: 'test-fcm-token-xyz',
        title: 'Breaking News',
        body: 'Something great happened!',
        imageUrl: 'https://example.com/banner.png',
        data: {'click_action': 'OPEN_APP', 'article_id': '99'},
        androidPriority: 'high',
        apnsBadge: 3,
      );

      final payload = message.toFcmPayload();

      expect(payload.containsKey('message'), isTrue);
      final msg = payload['message'] as Map<String, dynamic>;

      expect(msg['token'], 'test-fcm-token-xyz');
      expect(msg['notification']['title'], 'Breaking News');
      expect(msg['notification']['body'], 'Something great happened!');
      expect(msg['notification']['image'], 'https://example.com/banner.png');
      expect(msg['data']['article_id'], '99');
      expect(msg['android']['priority'], 'high');
      expect(msg['apns']['payload']['aps']['badge'], 3);
    });

    test('should build valid FCM v1 message for topic', () {
      const message = FcmMessageEntity(
        targetType: TargetType.topic,
        targetValue: 'weather_alerts',
        title: 'Rain Storm',
        body: 'Heavy rain expected',
      );

      final payload = message.toFcmPayload();
      final msg = payload['message'] as Map<String, dynamic>;

      expect(msg['topic'], 'weather_alerts');
      expect(msg.containsKey('token'), isFalse);
    });
  });

  group('FcmResponseModel Tests', () {
    test('should parse 200 success response with message ID', () {
      const sampleSuccessBody =
          '{"name": "projects/test-proj/messages/0:1620000000000000%abcdef"}';

      final model = FcmResponseModel.fromHttpResponse(
        statusCode: 200,
        body: sampleSuccessBody,
        headers: {'content-type': 'application/json; charset=UTF-8'},
        latencyMs: 125,
        requestUrl: 'https://fcm.googleapis.com/v1/projects/test-proj/messages:send',
        requestPayload: '{}',
      );

      expect(model.isSuccess, isTrue);
      expect(model.statusCode, 200);
      expect(model.messageId, 'projects/test-proj/messages/0:1620000000000000%abcdef');
      expect(model.errorMessage, isNull);
      expect(model.latencyMs, 125);
    });

    test('should parse 404 error response with Google API error details', () {
      const sampleErrorBody = '''
      {
        "error": {
          "code": 404,
          "message": "Requested entity was not found.",
          "status": "NOT_FOUND"
        }
      }
      ''';

      final model = FcmResponseModel.fromHttpResponse(
        statusCode: 404,
        body: sampleErrorBody,
        headers: {},
        latencyMs: 200,
        requestUrl: 'https://fcm.googleapis.com/v1/projects/test-proj/messages:send',
        requestPayload: '{}',
      );

      expect(model.isSuccess, isFalse);
      expect(model.statusCode, 404);
      expect(model.errorMessage, 'Requested entity was not found.');
    });
  });

  group('JsonUtils Tests', () {
    test('should prettify and validate JSON', () {
      const ugly = '{"a":1,"b":"hello"}';
      expect(JsonUtils.isValid(ugly), isTrue);
      expect(JsonUtils.isValid('bad'), isFalse);

      final pretty = JsonUtils.prettify(ugly);
      expect(pretty.contains('\n'), isTrue);
      expect(pretty.contains('  "a": 1'), isTrue);
    });

    test('should generate curl command', () {
      final curl = JsonUtils.generateCurl(
        url: 'https://fcm.googleapis.com/v1/projects/my-proj/messages:send',
        accessToken: 'ya29.testtoken',
        bodyJson: '{"message":{}}',
      );

      expect(curl.contains('curl -X POST'), isTrue);
      expect(curl.contains('Bearer ya29.testtoken'), isTrue);
      expect(curl.contains('https://fcm.googleapis.com'), isTrue);
    });
  });

  group('History Storage Subtyping Tests', () {
    test('should encode, decode and mutate history list with HistoryItemEntity without subtype error', () {
      final item1 = HistoryItemEntity(
        id: '1',
        timestamp: DateTime.now(),
        projectId: 'proj-1',
        target: 'tok-1',
        title: 'Title 1',
        body: 'Body 1',
        payloadJson: '{}',
        statusCode: 200,
        responseBody: 'ok',
        latencyMs: 50,
        isSuccess: true,
      );

      final encoded = HistoryItemModel.encodeList([item1]);
      final list = HistoryItemModel.decodeList(encoded);

      expect(list.length, 1);

      // Now insert another HistoryItemEntity into the list!
      final item2 = HistoryItemEntity(
        id: '2',
        timestamp: DateTime.now(),
        projectId: 'proj-2',
        target: 'tok-2',
        title: 'Title 2',
        body: 'Body 2',
        payloadJson: '{}',
        statusCode: 200,
        responseBody: 'ok',
        latencyMs: 60,
        isSuccess: true,
      );

      // This previously threw: type 'HistoryItemEntity' is not a subtype of type 'HistoryItemModel' of 'element'
      list.insert(0, item2);
      expect(list.length, 2);
      expect(list.first.id, '2');
    });
  });
}
