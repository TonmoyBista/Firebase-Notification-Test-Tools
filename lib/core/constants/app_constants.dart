class AppConstants {
  static const String fcmScope = 'https://www.googleapis.com/auth/firebase.messaging';
  static const String fcmBaseUrl = 'https://fcm.googleapis.com/v1/projects';

  static String getFcmSendUrl(String projectId) =>
      '$fcmBaseUrl/$projectId/messages:send';

  // Storage keys
  static const String keySavedServiceAccount = 'saved_service_account_json';
  static const String keyHistoryList = 'fcm_test_history_v1';
  static const String keyRememberAccount = 'remember_service_account';

  // Default notification templates
  static const String defaultNotificationTitle = 'Test Notification';
  static const String defaultNotificationBody =
      'Hello from Firebase Notification Tester! This is a test message.';
}
