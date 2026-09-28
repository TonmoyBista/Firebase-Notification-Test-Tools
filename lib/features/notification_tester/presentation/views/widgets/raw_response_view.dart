import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/core/utils/json_utils.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';

class RawResponseView extends StatefulWidget {
  const RawResponseView({super.key});

  @override
  State<RawResponseView> createState() => _RawResponseViewState();
}

class _RawResponseViewState extends State<RawResponseView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();
    final resp = vm.fcmResponse;

    if (resp == null) {
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terminal_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                'Raw FCM Response',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your payload and click "Send Notification" to view real-time HTTP response status, headers, and raw response body.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isSuccess = resp.isSuccess;
    final statusColor = isSuccess ? AppTheme.successGreen : AppTheme.errorRed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status, Latency, Actions
            Row(
              children: [
                // Status Code Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                        size: 15,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'HTTP ${resp.statusCode}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Latency Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.primaryAmber),
                      const SizedBox(width: 4),
                      Text(
                        '${resp.latencyMs} ms',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy Raw Response',
                  onPressed: () => _copyToClipboard(context, resp.rawBody, 'Raw Response'),
                ),
              ],
            ),

            if (resp.errorMessage != null && !isSuccess) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resp.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF8A80),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (resp.messageId != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 14, color: AppTheme.successGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Message: ${resp.messageId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppTheme.successGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Raw Response'),
                Tab(text: 'Formatted Body'),
                Tab(text: 'Response Headers'),
                Tab(text: 'cURL Command'),
              ],
            ),
            const SizedBox(height: 10),

            // Tab View Contents
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Raw Response Body
                  _CodeViewer(
                    content: resp.rawBody,
                    onCopy: () => _copyToClipboard(context, resp.rawBody, 'Raw Response'),
                  ),

                  // 2. Formatted JSON Body
                  _CodeViewer(
                    content: JsonUtils.prettify(resp.rawBody),
                    onCopy: () => _copyToClipboard(
                      context,
                      JsonUtils.prettify(resp.rawBody),
                      'Formatted JSON',
                    ),
                  ),

                  // 3. Response Headers
                  _HeadersViewer(headers: resp.headers),

                  // 4. cURL
                  _CodeViewer(
                    content: vm.getCurlCommand(),
                    onCopy: () => _copyToClipboard(context, vm.getCurlCommand(), 'cURL command'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeViewer extends StatelessWidget {
  final String content;
  final VoidCallback onCopy;

  const _CodeViewer({required this.content, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SelectableText(
              content.isEmpty ? '(Empty response body)' : content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF81D4FA),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white54),
              tooltip: 'Copy',
              onPressed: onCopy,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadersViewer extends StatelessWidget {
  final Map<String, String> headers;

  const _HeadersViewer({required this.headers});

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) {
      return const Center(child: Text('No headers available'));
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: headers.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final key = headers.keys.elementAt(i);
          final val = headers[key] ?? '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  '$key: ',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryAmber,
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    val,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
