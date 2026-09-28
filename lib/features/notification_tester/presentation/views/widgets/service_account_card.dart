import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class ServiceAccountCard extends StatelessWidget {
  const ServiceAccountCard({super.key});

  void _showPasteJsonDialog(BuildContext context, NotificationTesterViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.content_paste_rounded, color: AppTheme.primaryAmber),
            SizedBox(width: 8),
            Text('Paste Service Account JSON'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste the complete contents of your Firebase Service Account JSON file (downloaded from Firebase Console -> Project Settings -> Service accounts).',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 10,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: const InputDecoration(
                  hintText: '{\n  "type": "service_account",\n  "project_id": "...",\n  "private_key": "..."\n}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                vm.loadServiceAccountFromJson(text);
              }
            },
            child: const Text('Parse & Load'),
          ),
        ],
      ),
    );
  }

  void _showTokenDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key_rounded, color: AppTheme.primaryAmber),
            SizedBox(width: 8),
            Text('OAuth 2.0 Access Token'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Bearer token was generated from your service account private key and has scope "https://www.googleapis.com/auth/firebase.messaging".',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: SelectableText(
                  token,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Token'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Access Token copied to clipboard!')),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();
    final sa = vm.serviceAccount;
    final token = vm.authToken;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppTheme.primaryAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Service Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Authenticate via Google OAuth 2.0 to access FCM v1 API',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (vm.isTokenGenerating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            if (sa == null) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: vm.isTokenGenerating ? null : vm.pickServiceAccountFile,
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    label: const Text('Select JSON File'),
                  ),
                  OutlinedButton.icon(
                    onPressed: vm.isTokenGenerating ? null : () => _showPasteJsonDialog(context, vm),
                    icon: const Icon(Icons.paste_rounded, size: 18),
                    label: const Text('Paste JSON Text'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select your private_key.json downloaded from Firebase Console > Project Settings > Service Accounts',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ] else ...[
              // Loaded state
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_done_rounded, color: AppTheme.successGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Project ID: ',
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        SelectableText(
                          sa.projectId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryAmber,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          tooltip: 'Refresh Access Token',
                          onPressed: vm.isTokenGenerating ? null : vm.refreshAccessToken,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.errorRed),
                          tooltip: 'Unload Service Account',
                          onPressed: vm.clearServiceAccount,
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.alternate_email_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sa.clientEmail,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (token != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showTokenDialog(context, token.accessToken),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.successGreen),
                                  SizedBox(width: 4),
                                  Text(
                                    'Token Active',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
