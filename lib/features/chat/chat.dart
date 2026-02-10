// Chat Feature Barrel File

library chat;

//=========================
// Data Layer
//=========================

// Models
export 'data/models/message_model.dart';
export 'data/models/chat_room_model.dart';
export 'data/models/chat_room_member_model.dart';
export 'data/models/group_chat_model.dart';
export 'data/models/group_member_model.dart';

// Data Sources
export 'data/datasources/chat_remote_data_source.dart';

// Repositories
export 'data/repositories/chat_repository.dart';
export 'data/repositories/chat_repository_impl.dart';

//=========================
// Presentation Layer
//=========================

// ViewModels
export 'presentation/viewmodels/chat_list_viewmodel.dart';
export 'presentation/viewmodels/chat_room_viewmodel.dart';
export 'presentation/viewmodels/create_group_viewmodel.dart';
export 'presentation/viewmodels/select_user_viewmodel.dart';
export 'presentation/viewmodels/group_info_viewmodel.dart';
export 'presentation/viewmodels/your_group_viewmodel.dart';

// Views
export 'presentation/views/chat_list_page.dart';
export 'presentation/views/chat_room_page.dart';
export 'presentation/views/create_group_page.dart';
export 'presentation/views/join_group_page.dart';
export 'presentation/views/your_group_page.dart';
export 'presentation/views/select_user_page.dart';
export 'presentation/views/group_info_page.dart';
export 'presentation/views/full_image_view.dart';
export 'presentation/views/group_chat_success.dart';

// Widgets
export 'presentation/views/widgets/message_bubble.dart';
export 'presentation/views/widgets/message_options_sheet.dart';
export 'presentation/views/widgets/file_preview_dialog.dart';
export 'presentation/views/widgets/typing_indicator.dart';
export 'presentation/views/widgets/attachment_picker_sheet.dart';
export 'presentation/views/widgets/date_separator.dart';
export 'presentation/views/widgets/animated_typing_dot.dart';