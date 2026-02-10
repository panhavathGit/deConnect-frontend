// Profile Feature Barrel File

library profile;

//=========================
// Data Layer
//=========================

// Models
export 'data/models/profile_status.dart';

// Data Sources
export 'data/datasources/profile_remote_data_source.dart';
export 'data/datasources/profile_mock_data_source.dart';

// Repositories
export 'data/repositories/profile_repository.dart';
export 'data/repositories/profile_repository_impl.dart';

//=========================
// Presentation Layer
//=========================

// ViewModels
export 'presentation/viewmodels/profile_viewmodel.dart';

// Views
export 'presentation/views/profile_page.dart';
export 'presentation/views/edit_profile_page.dart';

// Widgets
export 'presentation/views/widgets/profile_card.dart';
export 'presentation/views/widgets/profile_post_item.dart';
export 'presentation/views/widgets/profile_loading_state.dart';
export 'presentation/views/widgets/profile_error_state.dart';