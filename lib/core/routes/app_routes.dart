class AppRoutes {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  AppRoutes._();

  // Auth & Onboarding 
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';

  // Feed 
  static const String feed = 'feed';
  static const String createPost = 'createPost';
  static const String postDetail = 'postDetail';
  static const String comments = 'comments';

  // Profile
  static const String profile = 'profile';
  static const String settings = 'settings'; 

  // Chat
  static const String chat = 'chat';
  static const String chatRoom = 'chatRoom';
}

class AppPaths {
  AppPaths._();
  
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String createPost = '/create-post';
  static const String feed = '/main';
  static const String profile = '/profile';
  static const String chat = '/chat';
  
  // Sub-paths (usually don't start with / in GoRouter sub-routes)
  static const String postDetail = 'post/:id';
  static const String comments = 'comments';
}