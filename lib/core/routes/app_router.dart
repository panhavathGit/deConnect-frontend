// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/feed/presentation/views/feed_page.dart';
import '../../features/profile/presentation/views/profile_page.dart';
import '../../features/chat/presentation/views/chat_list_page.dart';
import '../services/supabase_service.dart';
import '../../features/feed/presentation/views/post_detail_page.dart';
import '../../features/feed/presentation/views/comments_page.dart';
import '../../features/feed/data/models/feed_model.dart';
import '../../features/auth/presentation/views/register_screen.dart';
import '../../features/feed/presentation/views/create_post_page.dart';
import '../../features/splash/splash_screen.dart';

class AppRouter {

  // Development flag
  static const bool _bypassAuth = false;

  static final GoRouter router = GoRouter(
    
    debugLogDiagnostics: true,
    
    // Initial location
    initialLocation: '/splash',
    
    // Global redirect logic for authentication (no splash screen version)
    // redirect: (BuildContext context, GoRouterState state) {

    //   if(_bypassAuth) return null;

    //   final isLoggedIn = SupabaseService.client.auth.currentUser != null;
    //   final isGoingToLogin = state.matchedLocation == '/login';
    //   final isGoingToRegister = state.matchedLocation == '/register';

    //   // If user is not logged in and not going to auth pages, redirect to login
    //   if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
    //     return '/login';
    //   }

    //   // If user is logged in and going to auth pages, redirect to main
    //   if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
    //     return '/main';
    //   }

    //   // No redirect needed
    //   return null;
    // },

    // Global redirect logic for authentication (with splash screen)
    redirect: (BuildContext context, GoRouterState state) {
      if(_bypassAuth) return null;

      // IMPORTANT: Don't redirect if going to splash screen
      if (state.matchedLocation == '/splash') {
        return null; // Allow splash screen to show
      }

      final isLoggedIn = SupabaseService.client.auth.currentUser != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      // If user is not logged in and not going to auth pages, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // If user is logged in and going to auth pages, redirect to main
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return '/main';
      }

      // No redirect needed
      return null;
    },


    routes: [
      //splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          child: LoginScreen.builder(context),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => NoTransitionPage(
          child: RegisterScreen.builder(context),
        ),
      ),

      // Create Post Route (standalone, outside StatefulShellRoute)
      GoRoute(
        path: '/create-post',
        name: 'createPost',
        builder: (context, state) => CreatePostPage.builder(context),
      ),

      // Main App with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Feed Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main',
                name: 'feed',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FeedPage(),
                ),
                routes: [
                // Post Detail Route
                GoRoute(
                  path: 'post/:id',
                  name: 'postDetail',
                  builder: (context, state) {
                    final post = state.extra as FeedPost;
                    return PostDetailPage(post: post);
                  },
                  routes: [
                    // Comments Route
                    GoRoute(
                    path: 'comments',
                    name: 'comments',
                    builder: (context, state) {
                      final post = state.extra as FeedPost;
                      return CommentsPage.builder(context, post);  // Changed this line
                      },
                    ),
                  ],
                ),
              ],
                
              ),
            ],
          ),

          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
                routes: [
                  // Future: Add settings route
                  // GoRoute(
                  //   path: 'settings',
                  //   name: 'settings',
                  //   builder: (context, state) => const SettingsPage(),
                  // ),

                  
              
                ],
              ),
            ],
          ),

          // Chat Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatListPage(),
                ),
                routes: [
                  // Future: Add chat room route
                  // GoRoute(
                  //   path: 'room/:roomId',
                  //   name: 'chatRoom',
                  //   builder: (context, state) {
                  //     final roomId = state.pathParameters['roomId']!;
                  //     return ChatRoomPage(roomId: roomId);
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Scaffold with Bottom Navigation Bar
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        selectedItemColor: const Color(0xFF053CC7),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}