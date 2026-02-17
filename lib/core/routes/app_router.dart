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
import './app_routes.dart';

class AppRouter {

  // Development flag
  static const bool _bypassAuth = false;

  static GoRouter getRouter(GlobalKey<NavigatorState> navigatorKey) {
  
  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    
    // Initial location
    initialLocation: AppPaths.splash,

    // Global redirect logic for authentication (with splash screen)
    redirect: (BuildContext context, GoRouterState state) {
      if(_bypassAuth) return null;

      if (state.matchedLocation == AppPaths.splash) {
        return null; // Allow splash screen to show
      }

      final isLoggedIn = SupabaseService.client.auth.currentUser != null;
      final isGoingToLogin = state.matchedLocation == AppPaths.login;
      final isGoingToRegister = state.matchedLocation == AppPaths.register;

      // If user is not logged in and not going to auth pages, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppPaths.login;
      }

      // If user is logged in and going to auth pages, redirect to main
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppPaths.feed;
      }

      // No redirect needed
      return null;
    },


    routes: [
      //splash route
      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      // Auth Routes
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        pageBuilder: (context, state) => NoTransitionPage(
          child: LoginScreen.builder(context),
        ),
      ),
      GoRoute(
        path: AppPaths.register,
        name: AppRoutes.register,
        pageBuilder: (context, state) => NoTransitionPage(
          child: RegisterScreen.builder(context),
        ),
      ),

      // Create Post Route (standalone, outside StatefulShellRoute)
      GoRoute(
        path: AppPaths.createPost,
        name: AppRoutes.createPost,
        builder: (context, state) => CreatePostPage.builder(context),
      ),

      // Main App with Bottom Navigation, Define at the bottom
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Feed Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.feed,
                name: AppRoutes.feed,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FeedPage(),
                ),
                routes: [
                // Post Detail Route
                GoRoute(
                  path: AppPaths.postDetail, // 'post/:id'
                  name: AppRoutes.postDetail,
                  builder: (context, state) {
                    final post = state.extra as FeedPost;
                    return PostDetailPage(post: post);
                  },
                  routes: [
                    // Comments Route
                    GoRoute(
                    path: AppPaths.comments, // 'comments'
                    name: AppRoutes.comments,
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
                path: AppPaths.profile,
                name: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
                routes: [
            
                ],
              ),
            ],
          ),

          // Chat Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.chat,
                name: AppRoutes.chat,
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
              onPressed: () => context.goNamed(AppRoutes.feed),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  }
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