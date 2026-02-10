// lib/main_staging.dart

// --- Before using barrel file---
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'core/routes/app_router.dart';
// import 'core/services/supabase_service.dart';
// import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
// import 'features/feed/presentation/viewmodels/feed_viewmodel.dart';
// import 'features/feed/data/datasources/feed_remote_data_source.dart';
// import 'features/feed/data/datasources/feed_mock_data_source.dart';
// import 'features/chat/presentation/viewmodels/chat_list_viewmodel.dart';
// import 'features/feed/data/repositories/feed_repository_impl.dart';
// import 'features/feed/presentation/viewmodels/user_info_viewmodel.dart';
// import './features/chat/data/repositories/chat_repository_impl.dart';
// import './features/chat/data/datasources/chat_remote_data_source.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'core/theme/app_theme.dart';
// import 'core/config/env_config.dart';

// --- After using barrel file ---
import 'package:onboarding_project/core/app_export.dart';
import './features/feature.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load staging environment variables
  await dotenv.load(fileName: ".env.staging");
  EnvConfig.setEnvironment(Environment.staging);
  
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
      title: 'DeConnect (Staging)',
      theme: appTTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: true, // Show banner in staging
    );
  }
}
