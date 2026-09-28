import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class QuickTemplatesBar extends StatelessWidget {
  const QuickTemplatesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            'Presets:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          _TemplateChip(
            label: 'Standard Alert',
            icon: Icons.notifications_active_outlined,
            onTap: () => vm.applyTemplate('standard'),
          ),
          const SizedBox(width: 6),
          _TemplateChip(
            label: 'Data-Only (Silent)',
            icon: Icons.data_object_rounded,
            onTap: () => vm.applyTemplate('data_only'),
          ),
          const SizedBox(width: 6),
          _TemplateChip(
            label: 'Rich Image',
            icon: Icons.image_outlined,
            onTap: () => vm.applyTemplate('rich_media'),
          ),
          const SizedBox(width: 6),
          _TemplateChip(
            label: 'iOS Badge',
            icon: Icons.mark_chat_unread_outlined,
            onTap: () => vm.applyTemplate('ios_badge'),
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: AppTheme.primaryAmber),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.darkSurfaceVariant,
      side: const BorderSide(color: AppTheme.darkBorder),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onPressed: onTap,
    );
  }
}
