import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_notification_test_tools/core/constants/app_constants.dart';
import 'package:firebase_notification_test_tools/core/errors/failures.dart';
import 'package:firebase_notification_test_tools/core/utils/json_utils.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/auth_token_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/fcm_message_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/fcm_response_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/history_item_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/service_account_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/usecases/get_access_token_usecase.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/usecases/manage_history_usecase.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/usecases/parse_service_account_usecase.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/usecases/send_fcm_notification_usecase.dart';

class NotificationTesterViewModel extends ChangeNotifier {
  final ParseServiceAccountUseCase parseServiceAccountUseCase;
  final GetAccessTokenUseCase getAccessTokenUseCase;
  final SendFcmNotificationUseCase sendFcmNotificationUseCase;
  final ManageHistoryUseCase manageHistoryUseCase;

  NotificationTesterViewModel({
    required this.parseServiceAccountUseCase,
    required this.getAccessTokenUseCase,
    required this.sendFcmNotificationUseCase,
    required this.manageHistoryUseCase,
  }) {
    _initDefaults();
    _loadSavedData();
  }

  // --- State Variables ---
  ServiceAccountEntity? _serviceAccount;
  AuthTokenEntity? _authToken;
  FcmResponseEntity? _fcmResponse;

  bool _isLoading = false;
  bool _isTokenGenerating = false;
  String? _errorMessage;
  String? _successMessage;

  // Visual Form state
  TargetType _targetType = TargetType.token;
  final TextEditingController targetController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController apnsBadgeController = TextEditingController();

  String _androidPriority = 'high';
  final List<MapEntry<TextEditingController, TextEditingController>> _dataKeyValues = [];

  // Raw JSON state
  final TextEditingController rawJsonController = TextEditingController();
  bool _isRawJsonMode = false;
  bool _isSyncing = false;

  // History state
  List<HistoryItemEntity> _history = [];

  // --- Getters ---
  ServiceAccountEntity? get serviceAccount => _serviceAccount;
  AuthTokenEntity? get authToken => _authToken;
  FcmResponseEntity? get fcmResponse => _fcmResponse;
  bool get isLoading => _isLoading;
  bool get isTokenGenerating => _isTokenGenerating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  TargetType get targetType => _targetType;
  String get androidPriority => _androidPriority;
  List<MapEntry<TextEditingController, TextEditingController>> get dataKeyValues => _dataKeyValues;
  bool get isRawJsonMode => _isRawJsonMode;
  List<HistoryItemEntity> get history => _history;

  void _initDefaults() {
    titleController.text = AppConstants.defaultNotificationTitle;
    bodyController.text = AppConstants.defaultNotificationBody;
    targetController.text = '';
    _syncFormToRawJson();

    titleController.addListener(_onFormFieldChanged);
    bodyController.addListener(_onFormFieldChanged);
    imageUrlController.addListener(_onFormFieldChanged);
    targetController.addListener(_onFormFieldChanged);
    apnsBadgeController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    if (!_isRawJsonMode && !_isSyncing) {
      _syncFormToRawJson();
    }
  }

  Future<void> _loadSavedData() async {
    try {
      _history = await manageHistoryUseCase.getHistory();
      final savedJson = await manageHistoryUseCase.getSavedServiceAccount();
      if (savedJson != null && savedJson.isNotEmpty) {
        await loadServiceAccountFromJson(savedJson, saveLocally: false);
      }
      notifyListeners();
    } catch (_) {
      // Silently ignore loading errors
    }
  }

  void toggleJsonMode(bool isRaw) {
    if (_isRawJsonMode == isRaw) return;
    _isRawJsonMode = isRaw;
    if (_isRawJsonMode) {
      _syncFormToRawJson();
    } else {
      _syncRawJsonToForm();
    }
    notifyListeners();
  }

  void setTargetType(TargetType type) {
    _targetType = type;
    _syncFormToRawJson();
    notifyListeners();
  }

  void setAndroidPriority(String priority) {
    _androidPriority = priority;
    _syncFormToRawJson();
    notifyListeners();
  }

  void addDataField({String key = '', String value = ''}) {
    final keyCtrl = TextEditingController(text: key);
    final valCtrl = TextEditingController(text: value);
    keyCtrl.addListener(_onFormFieldChanged);
    valCtrl.addListener(_onFormFieldChanged);
    _dataKeyValues.add(MapEntry(keyCtrl, valCtrl));
    _syncFormToRawJson();
    notifyListeners();
  }

  void removeDataField(int index) {
    if (index >= 0 && index < _dataKeyValues.length) {
      _dataKeyValues[index].key.dispose();
      _dataKeyValues[index].value.dispose();
      _dataKeyValues.removeAt(index);
      _syncFormToRawJson();
      notifyListeners();
    }
  }

  // --- Syncing Logic ---
  void _syncFormToRawJson() {
    _isSyncing = true;
    final Map<String, String> dataMap = {};
    for (final entry in _dataKeyValues) {
      final k = entry.key.text.trim();
      final v = entry.value.text.trim();
      if (k.isNotEmpty) {
        dataMap[k] = v;
      }
    }

    final entity = FcmMessageEntity(
      targetType: _targetType,
      targetValue: targetController.text.trim(),
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
      imageUrl: imageUrlController.text.trim(),
      data: dataMap,
      androidPriority: _androidPriority,
      apnsBadge: int.tryParse(apnsBadgeController.text.trim()),
    );

    final payloadMap = entity.toFcmPayload();
    rawJsonController.text = JsonUtils.formatMap(payloadMap);
    _isSyncing = false;
  }

  void _syncRawJsonToForm() {
    _isSyncing = true;
    final rawText = rawJsonController.text.trim();
    final map = JsonUtils.tryParse(rawText);
    if (map != null && map.containsKey('message')) {
      final msg = map['message'] as Map<String, dynamic>;

      if (msg.containsKey('token')) {
        _targetType = TargetType.token;
        targetController.text = msg['token']?.toString() ?? '';
      } else if (msg.containsKey('topic')) {
        _targetType = TargetType.topic;
        targetController.text = msg['topic']?.toString() ?? '';
      } else if (msg.containsKey('condition')) {
        _targetType = TargetType.condition;
        targetController.text = msg['condition']?.toString() ?? '';
      }

      if (msg.containsKey('notification')) {
        final notif = msg['notification'] as Map<String, dynamic>;
        titleController.text = notif['title']?.toString() ?? '';
        bodyController.text = notif['body']?.toString() ?? '';
        imageUrlController.text = notif['image']?.toString() ?? '';
      }

      if (msg.containsKey('data') && msg['data'] is Map<String, dynamic>) {
        final dMap = msg['data'] as Map<String, dynamic>;
        for (var entry in _dataKeyValues) {
          entry.key.dispose();
          entry.value.dispose();
        }
        _dataKeyValues.clear();
        dMap.forEach((k, v) {
          final kCtrl = TextEditingController(text: k)..addListener(_onFormFieldChanged);
          final vCtrl = TextEditingController(text: v.toString())..addListener(_onFormFieldChanged);
          _dataKeyValues.add(MapEntry(kCtrl, vCtrl));
        });
      }
    }
    _isSyncing = false;
  }

  // --- Template Apply ---
  void applyTemplate(String templateName) {
    switch (templateName) {
      case 'standard':
        titleController.text = 'Important Update';
        bodyController.text = 'This is a standard push notification message.';
        imageUrlController.clear();
        _androidPriority = 'high';
        break;
      case 'data_only':
        titleController.clear();
        bodyController.clear();
        imageUrlController.clear();
        for (var entry in _dataKeyValues) {
          entry.key.dispose();
          entry.value.dispose();
        }
        _dataKeyValues.clear();
        addDataField(key: 'action', value: 'SYNC_DATABASE');
        addDataField(key: 'content_id', value: '45912');
        addDataField(key: 'timestamp', value: DateTime.now().millisecondsSinceEpoch.toString());
        break;
      case 'rich_media':
        titleController.text = 'New Photo Shared! 📸';
        bodyController.text = 'Check out the latest photo in your feed.';
        imageUrlController.text = 'https://picsum.photos/600/400';
        _androidPriority = 'high';
        break;
      case 'ios_badge':
        titleController.text = 'New Chat Message';
        bodyController.text = 'You have 1 unread message from Alice.';
        apnsBadgeController.text = '1';
        break;
    }
    _syncFormToRawJson();
    notifyListeners();
  }

  // --- Service Account Selection ---
  Future<void> pickServiceAccountFile() async {
    _clearMessages();
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) {
        return;
      }

      final jsonContent = await file.xFile.readAsString();
      await loadServiceAccountFromJson(jsonContent, saveLocally: true);
    } catch (e) {
      _errorMessage = 'Failed to load file: $e';
      notifyListeners();
    }
  }

  Future<void> loadServiceAccountFromJson(String jsonString, {bool saveLocally = true}) async {
    _clearMessages();
    _isTokenGenerating = true;
    notifyListeners();

    try {
      final parsed = parseServiceAccountUseCase.execute(jsonString);
      _serviceAccount = parsed;

      // Auto-generate OAuth access token
      final token = await getAccessTokenUseCase.execute(parsed);
      _authToken = token;

      if (saveLocally) {
        await manageHistoryUseCase.saveServiceAccount(jsonString);
      }

      _successMessage = 'Loaded project: ${parsed.projectId}';
    } catch (e) {
      _errorMessage = e.toString();
      _serviceAccount = null;
      _authToken = null;
    } finally {
      _isTokenGenerating = false;
      notifyListeners();
    }
  }

  Future<void> refreshAccessToken() async {
    if (_serviceAccount == null) return;
    _clearMessages();
    _isTokenGenerating = true;
    notifyListeners();

    try {
      final token = await getAccessTokenUseCase.execute(_serviceAccount!);
      _authToken = token;
      _successMessage = 'Access token refreshed successfully.';
    } catch (e) {
      _errorMessage = 'Failed to refresh token: $e';
    } finally {
      _isTokenGenerating = false;
      notifyListeners();
    }
  }

  Future<void> clearServiceAccount() async {
    _serviceAccount = null;
    _authToken = null;
    await manageHistoryUseCase.clearSavedServiceAccount();
    _clearMessages();
    notifyListeners();
  }

  // --- Send FCM Notification ---
  Future<void> sendNotification() async {
    _clearMessages();

    if (_serviceAccount == null) {
      _errorMessage = 'Please select a Firebase Service Account JSON first.';
      notifyListeners();
      return;
    }

    if (_authToken == null || _authToken!.isExpired) {
      // Refresh token if needed
      await refreshAccessToken();
      if (_authToken == null) return;
    }

    // Verify payload JSON
    String payload = rawJsonController.text.trim();
    if (payload.isEmpty) {
      _syncFormToRawJson();
      payload = rawJsonController.text.trim();
    }

    if (!JsonUtils.isValid(payload)) {
      _errorMessage = 'The message payload contains invalid JSON syntax.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await sendFcmNotificationUseCase.execute(
        projectId: _serviceAccount!.projectId,
        accessToken: _authToken!.accessToken,
        messagePayloadJson: payload,
      );

      _fcmResponse = response;

      if (response.isSuccess) {
        _successMessage = 'Notification sent successfully! (Status: ${response.statusCode})';
      } else {
        _errorMessage = 'Send failed with status: ${response.statusCode}';
      }

      // Add to history
      final historyItem = HistoryItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        projectId: _serviceAccount!.projectId,
        target: _targetType == TargetType.token
            ? (targetController.text.length > 20
                ? '${targetController.text.substring(0, 15)}...'
                : targetController.text)
            : targetController.text,
        title: titleController.text,
        body: bodyController.text,
        payloadJson: payload,
        statusCode: response.statusCode,
        responseBody: response.rawBody,
        latencyMs: response.latencyMs,
        isSuccess: response.isSuccess,
      );

      await manageHistoryUseCase.addHistory(historyItem);
      _history = await manageHistoryUseCase.getHistory();
    } on Failure catch (f) {
      _errorMessage = f.message;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadFromHistory(HistoryItemEntity item) {
    rawJsonController.text = JsonUtils.prettify(item.payloadJson);
    _syncRawJsonToForm();
    notifyListeners();
  }

  Future<void> deleteHistoryItem(String id) async {
    await manageHistoryUseCase.deleteHistory(id);
    _history = await manageHistoryUseCase.getHistory();
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await manageHistoryUseCase.clearHistory();
    _history = [];
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String getCurlCommand() {
    if (_serviceAccount == null) return '';
    return JsonUtils.generateCurl(
      url: AppConstants.getFcmSendUrl(_serviceAccount!.projectId),
      accessToken: _authToken?.accessToken ?? '<ACCESS_TOKEN>',
      bodyJson: rawJsonController.text.trim(),
    );
  }

  @override
  void dispose() {
    targetController.dispose();
    titleController.dispose();
    bodyController.dispose();
    imageUrlController.dispose();
    apnsBadgeController.dispose();
    rawJsonController.dispose();
    for (var entry in _dataKeyValues) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }
}
