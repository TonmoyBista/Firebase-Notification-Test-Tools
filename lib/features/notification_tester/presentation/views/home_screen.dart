import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_notification_test_tools/core/theme/app_theme.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/history_drawer.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/quick_templates_bar.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/raw_json_editor.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/raw_response_view.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/service_account_card.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/target_type_selector.dart';
import 'package:firebase_notification_test_tools/features/notification_tester/presentation/views/widgets/visual_payload_editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppTheme.primaryAmber),
            SizedBox(width: 8),
            Text('Firebase Notification Test Tools'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'How to use this tool:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _helpStep('1', 'Firebase Service Account JSON',
                    'Go to Firebase Console > Project Settings > Service accounts > "Generate new private key". Select or paste that JSON into this app.'),
                _helpStep('2', 'Automatic Authentication',
                    'The app extracts your Project ID and securely mints an OAuth 2.0 Bearer token via Google OAuth2 with the required firebase.messaging scope.'),
                _helpStep('3', 'Configure Message',
                    'Enter your destination Device Token (FCM token), Topic, or Condition. Adjust Title, Body, Custom Data, or switch to Raw JSON mode.'),
                _helpStep('4', 'Send & View Raw Response',
                    'Click "Send Notification". The app calls https://fcm.googleapis.com/v1/projects/<projectId>/messages:send and renders the raw server response, status code, latency, and headers.'),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _helpStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAmber),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationTesterViewModel>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    // Single-shot consumed snackbars (Fix for persistent snackbar bug)
    final error = vm.consumeErrorMessage();
    final success = vm.consumeSuccessMessage();
    if (error != null || success != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (error != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (success != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(success),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HistoryDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.primaryAmber,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Firebase Notification Test Tools',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'v1 API',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryAmber),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Instructions & Guide',
            onPressed: () => _showHelpDialog(context),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: vm.history.isNotEmpty,
              label: Text('${vm.history.length}'),
              child: const Icon(Icons.history_rounded),
            ),
            tooltip: 'Request History',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop ? _buildDesktopLayout(context, vm) : _buildMobileLayout(context, vm),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, NotificationTesterViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Configuration & Payload Builder with KEEP-IN-PLACE Send Button
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ServiceAccountCard(),
                      const SizedBox(height: 14),
                      const QuickTemplatesBar(),
                      const SizedBox(height: 14),
                      _buildPayloadCard(context, vm),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Fixed, persistent bottom bar keeping Send Notification button in place
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border(
                    top: BorderSide(color: AppTheme.darkBorder),
                    right: BorderSide(color: AppTheme.darkBorder),
                  ),
                ),
                child: _buildSendButton(vm),
              ),
            ],
          ),
        ),

        // Right Column: Raw Response Inspector
        const Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RawResponseView(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, NotificationTesterViewModel vm) {
    return Column(
      children: [
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: AppTheme.darkSurface,
                  child: TabBar(
                    tabs: [
                      const Tab(icon: Icon(Icons.edit_note_rounded), text: 'Message Builder'),
                      Tab(
                        icon: Badge(
                          isLabelVisible: vm.fcmResponse != null,
                          backgroundColor: vm.fcmResponse?.isSuccess == true
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                          child: const Icon(Icons.terminal_rounded),
                        ),
                        text: 'Raw Response',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ServiceAccountCard(),
                            const SizedBox(height: 14),
                            const QuickTemplatesBar(),
                            const SizedBox(height: 14),
                            _buildPayloadCard(context, vm),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: RawResponseView(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Persistent bottom Send button on mobile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.darkSurface,
            border: Border(
              top: BorderSide(color: AppTheme.darkBorder),
            ),
          ),
          child: SafeArea(
            top: false,
            child: _buildSendButton(vm),
          ),
        ),
      ],
    );
  }

  Widget _buildPayloadCard(BuildContext context, NotificationTesterViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.outgoing_mail, color: AppTheme.primaryAmber, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Message Configuration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                // Toggle Visual / Raw JSON
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Visual Form', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.dashboard_customize_outlined, size: 14),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Raw JSON', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.code_rounded, size: 14),
                    ),
                  ],
                  selected: {vm.isRawJsonMode},
                  onSelectionChanged: (set) => vm.toggleJsonMode(set.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.primaryAmber.withValues(alpha: 0.2);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.primaryAmber;
                      }
                      return Colors.white70;
                    }),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const TargetTypeSelector(),
            const SizedBox(height: 16),
            if (!vm.isRawJsonMode) const VisualPayloadEditor() else const RawJsonEditor(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(NotificationTesterViewModel vm) {
    final isReady = vm.serviceAccount != null && !vm.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? AppTheme.primaryAmber : Colors.grey.shade800,
          foregroundColor: isReady ? Colors.black : Colors.white38,
        ),
        onPressed: isReady ? vm.sendNotification : null,
        icon: vm.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          vm.isLoading
              ? 'Sending via FCM v1 API...'
              : (vm.serviceAccount == null
                  ? 'Select Service Account to Send'
                  : 'Send Notification'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
