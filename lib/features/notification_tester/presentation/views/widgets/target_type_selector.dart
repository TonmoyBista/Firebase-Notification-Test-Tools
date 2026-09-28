import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/fcm_message_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class TargetTypeSelector extends StatelessWidget {
  const TargetTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Target Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  'Token: Direct device FCM token\nTopic: e.g. "news" or "all"\nCondition: e.g. "\'dogs\' in topics || \'cats\' in topics"',
              child: Icon(Icons.info_outline_rounded, size: 15, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SegmentedButton<TargetType>(
          segments: const [
            ButtonSegment(
              value: TargetType.token,
              label: Text('Device Token'),
              icon: Icon(Icons.phone_android_rounded, size: 16),
            ),
            ButtonSegment(
              value: TargetType.topic,
              label: Text('Topic'),
              icon: Icon(Icons.tag_rounded, size: 16),
            ),
            ButtonSegment(
              value: TargetType.condition,
              label: Text('Condition'),
              icon: Icon(Icons.alt_route_rounded, size: 16),
            ),
          ],
          selected: {vm.targetType},
          onSelectionChanged: (newSelection) {
            vm.setTargetType(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primaryAmber.withValues(alpha: 0.2);
              }
              return AppTheme.darkSurfaceVariant;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primaryAmber;
              }
              return Colors.white70;
            }),
            side: WidgetStateProperty.all(const BorderSide(color: AppTheme.darkBorder)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: vm.targetController,
          decoration: InputDecoration(
            labelText: vm.targetType == TargetType.token
                ? 'Device Registration Token (FCM Token)'
                : vm.targetType == TargetType.topic
                    ? 'Topic Name (e.g. news)'
                    : 'Condition Expression (e.g. \'sports\' in topics)',
            hintText: vm.targetType == TargetType.token
                ? 'e.g. dK3J8... (paste device token from mobile app)'
                : vm.targetType == TargetType.topic
                    ? 'news'
                    : '\'sports\' in topics || \'tech\' in topics',
            prefixIcon: Icon(
              vm.targetType == TargetType.token
                  ? Icons.vpn_key_outlined
                  : vm.targetType == TargetType.topic
                      ? Icons.tag
                      : Icons.rule_rounded,
              size: 18,
            ),
            suffixIcon: vm.targetController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => vm.targetController.clear(),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
