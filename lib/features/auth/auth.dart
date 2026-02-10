// Auth Feature Barrel File

library auth;

//=========================
// Data Layer
//=========================

// Models
export 'data/models/auth_model.dart';
export 'data/models/user_model.dart';

// Repositories
export 'data/repositories/auth_repository.dart';

//=========================
// Presentation Layer
//=========================

// ViewModels
export 'presentation/viewmodels/auth_viewmodel.dart';

// Views
export 'presentation/views/login_screen.dart';
export 'presentation/views/register_screen.dart';