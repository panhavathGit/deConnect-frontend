// lib/main_prod.dart
import 'package:onboarding_project/core/app_export.dart';
import './features/feature.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load production environment variables
  await dotenv.load(fileName: ".env.prod");
  EnvConfig.setEnvironment(Environment.prod);
  
  await SupabaseService.initialize();

  // Initialize data sources
  final feedRemoteDataSource = FeedRemoteDataSourceImpl();
  final feedMockDataSource = FeedMockDataSourceImpl();
  final chatRemoteDataSource = ChatRemoteDataSourceImpl();

  // Initialize repository
  final feedRepository = FeedRepositoryImpl(
    remoteDataSource: feedRemoteDataSource,
    mockDataSource: feedMockDataSource,
    useMockData: false,
  );
  final chatRepository = ChatRepositoryImpl(
    remoteDataSource: chatRemoteDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserInfoViewModel()), 
        ChangeNotifierProvider(
          create: (_) => FeedViewModel(repository: feedRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatListViewModel(repository: chatRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeConnect',
      theme: appTTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false, // No banner in production
    );
  }
}
