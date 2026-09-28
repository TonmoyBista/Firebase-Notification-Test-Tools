import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/notification_tester/data/datasources/fcm_remote_datasource.dart';
import 'features/notification_tester/data/datasources/local_storage_datasource.dart';
import 'features/notification_tester/data/repositories/fcm_repository_impl.dart';
import 'features/notification_tester/data/repositories/storage_repository_impl.dart';
import 'features/notification_tester/domain/usecases/get_access_token_usecase.dart';
import 'features/notification_tester/domain/usecases/manage_history_usecase.dart';
import 'features/notification_tester/domain/usecases/parse_service_account_usecase.dart';
import 'features/notification_tester/domain/usecases/send_fcm_notification_usecase.dart';
import 'features/notification_tester/presentation/viewmodels/notification_tester_viewmodel.dart';
import 'features/notification_tester/presentation/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FcmTesterApp());
}

class FcmTesterApp extends StatelessWidget {
  final NotificationTesterViewModel? viewModel;

  const FcmTesterApp({super.key, this.viewModel});

  static NotificationTesterViewModel createDefaultViewModel() {
    final fcmRemoteDataSource = FcmRemoteDataSourceImpl();
    final localStorageDataSource = LocalStorageDataSourceImpl();

    final fcmRepository = FcmRepositoryImpl(remoteDataSource: fcmRemoteDataSource);
    final storageRepository = StorageRepositoryImpl(dataSource: localStorageDataSource);

    final parseServiceAccountUseCase = ParseServiceAccountUseCase();
    final getAccessTokenUseCase = GetAccessTokenUseCase(fcmRepository);
    final sendFcmNotificationUseCase = SendFcmNotificationUseCase(fcmRepository);
    final manageHistoryUseCase = ManageHistoryUseCase(storageRepository);

    return NotificationTesterViewModel(
      parseServiceAccountUseCase: parseServiceAccountUseCase,
      getAccessTokenUseCase: getAccessTokenUseCase,
      sendFcmNotificationUseCase: sendFcmNotificationUseCase,
      manageHistoryUseCase: manageHistoryUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => viewModel ?? createDefaultViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Firebase Notification Test Tools',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
