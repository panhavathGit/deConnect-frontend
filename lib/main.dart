import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/feed/viewmodels/feed_viewmodel.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/auth/views/login_page.dart';
import 'features/feed/views/feed_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => FeedViewModel()),
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
    // Check if user is already logged in
    final isLoggedIn = SupabaseService.client.auth.currentUser != null;

    return MaterialApp(
      title: 'DeConnect',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: isLoggedIn ? const FeedPage() : LoginPage(),
    );
  }
}