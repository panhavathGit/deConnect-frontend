import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/app_export.dart';
import './features/feature.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:onboarding_project/core/utils/logger.dart';

/// Background handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.d('[Background] message received: ${message.messageId}');
}

/// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Register background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Load environment
  await dotenv.load(fileName: ".env.dev");
  EnvConfig.setEnvironment(Environment.dev);

  /// Initialize Supabase
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserInfoViewModel()),
        ChangeNotifierProvider(
          create: (_) => FeedViewModel(
            repository: FeedRepositoryImpl(
              remoteDataSource: FeedRemoteDataSourceImpl(),
              mockDataSource: FeedMockDataSourceImpl(),
              useMockData: false,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatListViewModel(
            repository: ChatRepositoryImpl(
              remoteDataSource: ChatRemoteDataSourceImpl(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) {
          final currentUserId =
              SupabaseService.client.auth.currentUser?.id ?? 'user1';
          return ProfileViewModel(
            repository: ProfileRepositoryImpl(
              remoteDataSource: ProfileRemoteDataSourceImpl(),
              mockDataSource: ProfileMockDataSourceImpl(),
              useMockData: false,
            ),
            userId: currentUserId,
          )..loadProfile();
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    /// Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      AppLogger.w('Notification permission status: $status');
    }

    /// Initialize NotificationService
    await NotificationService.instance.initialize(
      navigatorKey: navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeConnect (Dev)',
      theme: appTTheme,
      routerConfig: AppRouter.getRouter(navigatorKey),
      debugShowCheckedModeBanner: true,
    );
  }
}

