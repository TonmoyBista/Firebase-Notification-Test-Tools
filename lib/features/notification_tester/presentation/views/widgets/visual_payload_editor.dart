import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class VisualPayloadEditor extends StatelessWidget {
  const VisualPayloadEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextField(
          controller: vm.titleController,
          decoration: const InputDecoration(
            labelText: 'Notification Title',
            hintText: 'Enter title (optional for data-only messages)',
            prefixIcon: Icon(Icons.title_rounded, size: 18),
          ),
        ),
        const SizedBox(height: 12),

        // Body
        TextField(
          controller: vm.bodyController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notification Body',
            hintText: 'Enter notification message text...',
            prefixIcon: Icon(Icons.message_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 12),

        // Image URL
        TextField(
          controller: vm.imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Image URL (Optional)',
            hintText: 'https://example.com/image.png',
            prefixIcon: Icon(Icons.image_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 16),

        // Platform Options (Android & iOS)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkSurfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16, color: AppTheme.primaryAmber),
                  SizedBox(width: 6),
                  Text(
                    'Platform Specific Config',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Android Priority
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: vm.androidPriority,
                      decoration: const InputDecoration(
                        labelText: 'Android Priority',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'high', child: Text('High (Heads-up)')),
                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      ],
                      onChanged: (val) {
                        if (val != null) vm.setAndroidPriority(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // iOS Badge
                  Expanded(
                    child: TextField(
                      controller: vm.apnsBadgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'iOS APNs Badge',
                        hintText: 'e.g. 1',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Custom Key-Value Data Payload
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.dataset_outlined, size: 16, color: AppTheme.primaryAmber),
                SizedBox(width: 6),
                Text(
                  'Custom Key-Value Data',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => vm.addDataField(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Key-Value'),
            ),
          ],
        ),
        if (vm.dataKeyValues.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No custom data key-values added. Click "Add Key-Value" to include custom payload.',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.dataKeyValues.length,
            itemBuilder: (ctx, index) {
              final pair = vm.dataKeyValues[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: pair.key,
                        decoration: const InputDecoration(
                          hintText: 'Key (e.g. user_id)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: pair.value,
                        decoration: const InputDecoration(
                          hintText: 'Value (e.g. 12345)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.errorRed),
                      tooltip: 'Remove',
                      onPressed: () => vm.removeDataField(index),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
