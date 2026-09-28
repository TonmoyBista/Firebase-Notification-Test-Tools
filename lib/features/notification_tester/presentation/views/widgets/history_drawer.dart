import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/domain/entities/history_item_entity.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class HistoryDrawer extends StatelessWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();
    final history = vm.history;

    return Drawer(
      backgroundColor: AppTheme.darkBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppTheme.primaryAmber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Request History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (history.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, size: 20, color: AppTheme.errorRed),
                      tooltip: 'Clear All History',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear All History?'),
                            content: const Text('This will remove all recorded notification test runs.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  vm.clearAllHistory();
                                },
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (history.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          size: 40, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        'No test runs recorded yet',
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = history[i];
                    return _HistoryTile(item: item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItemEntity item;

  const _HistoryTile({required this.item});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<NotificationTesterViewModel>();
    final isSuccess = item.isSuccess;
    final color = isSuccess ? AppTheme.successGreen : AppTheme.errorRed;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isSuccess ? Icons.check_circle_outline : Icons.error_outline,
          color: color,
          size: 18,
        ),
      ),
      title: Row(
        children: [
          Text(
            'HTTP ${item.statusCode}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '⚡ ${item.latencyMs}ms',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const Spacer(),
          Text(
            _formatTime(item.timestamp),
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (item.title.isNotEmpty)
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          Text(
            'Target: ${item.target.isEmpty ? "None" : item.target}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
        tooltip: 'Delete',
        onPressed: () => vm.deleteHistoryItem(item.id),
      ),
      onTap: () {
        vm.loadFromHistory(item);
        Navigator.pop(context); // close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payload reloaded from history!')),
        );
      },
    );
  }
}
