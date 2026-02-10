// Feed Feature Barrel File

library feed;

//=========================
// Data Layer
//=========================

// Models
export 'data/models/feed_model.dart';
export 'data/models/comment_model.dart';

// Data Sources
export 'data/datasources/feed_remote_data_source.dart';
export 'data/datasources/feed_mock_data_source.dart';
export 'data/datasources/comment_remote_data_source.dart';
export 'data/datasources/comment_mock_data_source.dart';

// Repositories
export 'data/repositories/feed_repository.dart';
export 'data/repositories/feed_repository_impl.dart';
export 'data/repositories/comment_repository.dart';
export 'data/repositories/comment_repository_impl.dart';

//=========================
// Presentation Layer
//=========================

// ViewModels
export 'presentation/viewmodels/feed_viewmodel.dart';
export 'presentation/viewmodels/user_info_viewmodel.dart';
export 'presentation/viewmodels/create_post_viewmodel.dart';
export 'presentation/viewmodels/comment_viewmodel.dart';

// Views
export 'presentation/views/feed_page.dart';
export 'presentation/views/post_detail_page.dart';
export 'presentation/views/comments_page.dart';
export 'presentation/views/create_post_page.dart';
export 'presentation/views/edit_post_page.dart';