import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/feed/viewmodels/feed_viewmodel.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/auth/views/login_page.dart';
import 'features/feed/views/feed_page.dart';

void main() {
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
    return MaterialApp(
      title: 'DeConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return authVM.isLoggedIn ? const FeedPage() : LoginPage();
        },
      ),
    );
  }
}