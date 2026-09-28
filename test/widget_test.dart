import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_notification_test_tools/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FCM Tester App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FcmTesterApp());
    await tester.pump();

    // Verify app title or core elements exist
    expect(find.text('FCM Notification Tester'), findsOneWidget);
    expect(find.text('Firebase Service Account'), findsOneWidget);
    expect(find.text('Message Configuration'), findsOneWidget);
  });
}
