// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/feed/presentation/viewmodels/feed_viewmodel.dart';
import 'features/feed/data/datasources/feed_remote_data_source.dart';
import 'features/feed/data/datasources/feed_mock_data_source.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  // Initialize data sources
  final feedRemoteDataSource = FeedRemoteDataSourceImpl();
  final feedMockDataSource = FeedMockDataSourceImpl();

  // Initialize repository
  final feedRepository = FeedRepositoryImpl(
    remoteDataSource: feedRemoteDataSource,
    mockDataSource: feedMockDataSource,
    useMockData: true, // Toggle this when you have real backend
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => FeedViewModel(repository: feedRepository),
        ),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}