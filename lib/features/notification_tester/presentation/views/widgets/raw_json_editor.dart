import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/core/utils/json_utils.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class RawJsonEditor extends StatelessWidget {
  const RawJsonEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();
    final isValid = JsonUtils.isValid(vm.rawJsonController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isValid ? AppTheme.successGreen : AppTheme.errorRed).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: (isValid ? AppTheme.successGreen : AppTheme.errorRed).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isValid ? Icons.check_circle_outline : Icons.error_outline,
                    size: 13,
                    color: isValid ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isValid ? 'Valid JSON' : 'Invalid JSON Syntax',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isValid ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
              label: const Text('Prettify', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onPressed: () {
                vm.rawJsonController.text = JsonUtils.prettify(vm.rawJsonController.text);
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              tooltip: 'Copy JSON Payload',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: vm.rawJsonController.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payload copied to clipboard!')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1115),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid ? AppTheme.darkBorder : AppTheme.errorRed.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: vm.rawJsonController,
            maxLines: 18,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.4,
              color: Color(0xFFE2E8F0),
            ),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
              hintText: '{\n  "message": {\n    "token": "...",\n    "notification": {\n      "title": "...",\n      "body": "..."\n    }\n  }\n}',
            ),
          ),
        ),
      ],
    );
  }
}
