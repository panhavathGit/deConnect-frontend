// // lib/features/chat/views/select_user_page.dart

// import 'package:onboarding_project/core/app_export.dart';
// import '../../chat.dart';
// import '../../../profile/profile.dart';

// class SelectUserPage extends StatefulWidget {
//   const SelectUserPage({super.key});

//   @override
//   State<SelectUserPage> createState() => _SelectUserPageState();
// }

// class _SelectUserPageState extends State<SelectUserPage> {
//   late SelectUserViewModel _viewModel;
//   bool _isNavigating = false;

//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _viewModel = SelectUserViewModel(
//       profileDataSource: ProfileRemoteDataSourceImpl(),
//       chatRepository: ChatRepositoryImpl(
//         remoteDataSource: ChatRemoteDataSourceImpl(),
//       ),
//     );
//     _viewModel.loadUsers();
//   }

//   @override
//   void dispose() {
//     _viewModel.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _startChat(String userId) async {
//     if (_isNavigating) {
//       debugPrint('⚠️ Already navigating, ignoring tap');
//       return;
//     }

//     setState(() {
//       _isNavigating = true;
//     });

//     try {
//       final room = await _viewModel.createChatWithUser(userId);

//       if (mounted && room != null) {
//         await Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatRoomPage(
//               roomId: room.id,
//               roomName: room.displayName,
//             ),
//           ),
//         );
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to create chat'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isNavigating = false;
//         });
//       }
//     }
//   }

//   void _onSearchChanged(String query) {
//     _viewModel.updateSearchQuery(query);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final isDark = context.watch<ThemeProvider>().isDarkMode;
//     final isDark = false;
    
//     return ChangeNotifierProvider.value(
//       value: _viewModel,
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF121212) : appTheme.white_A700,
//         appBar: AppBar(
//           title: Text(
//             'Select User',
//             style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//               fontSize: 20,
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
//           foregroundColor: Colors.white,
//         ),
//         body: Stack(
//           children: [
//             Consumer<SelectUserViewModel>(
//               builder: (context, viewModel, _) {
//                 if (viewModel.isLoading) {
//                   return Center(
//                     child: CircularProgressIndicator(color: appTheme.blue_900),
//                   );
//                 }

//                 if (viewModel.status == SelectUserStatus.error) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                         const SizedBox(height: 16),
//                         Text(
//                           viewModel.errorMessage ?? 'Failed to load users',
//                           style: TextStyleHelper.instance.body15MediumInter.copyWith(
//                             color: isDark ? Colors.white : null,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () => viewModel.loadUsers(),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: appTheme.blue_900,
//                           ),
//                           child: const Text('Retry', style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (viewModel.users.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.people_outline,
//                           size: 64,
//                           color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No users found',
//                           style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//                             color: isDark ? Colors.white : null,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.separated(
//                   itemCount: viewModel.users.length,
//                   separatorBuilder: (context, index) => Divider(
//                     height: 1,
//                     color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
//                   ),
//                   itemBuilder: (context, index) {
//                     final user = viewModel.users[index];
//                     return ListTile(
//                       tileColor: isDark ? const Color(0xFF121212) : null,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 8,
//                       ),
//                       leading: CircleAvatar(
//                         radius: 28,
//                         backgroundColor: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
//                         child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
//                             ? ClipOval(
//                                 child: Image.network(
//                                   user.avatarUrl!,
//                                   width: 56,
//                                   height: 56,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Icon(
//                                       Icons.person,
//                                       size: 32,
//                                       color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                                     );
//                                   },
//                                   loadingBuilder: (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Icon(
//                                       Icons.person,
//                                       size: 32,
//                                       color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                                     );
//                                   },
//                                 ),
//                               )
//                             : Icon(
//                                 Icons.person,
//                                 size: 32,
//                                 color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                               ),
//                       ),
//                       title: Text(
//                         user.name,
//                         style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//                           fontSize: 16,
//                           color: isDark ? Colors.white : null,
//                         ),
//                       ),
//                       subtitle: user.bio != null
//                           ? Text(
//                               user.bio!,
//                               style: TextStyleHelper.instance.body15MediumInter.copyWith(
//                                 color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             )
//                           : null,
//                       onTap: _isNavigating ? null : () => _startChat(user.id),
//                     );
//                   },
//                 );
//               },
//             ),

//             // Loading overlay
//             if (_isNavigating)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: Center(
//                   child: Card(
//                     color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircularProgressIndicator(color: appTheme.blue_900),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Starting chat...',
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/features/chat/presentation/views/select_user_page.dart

import 'package:onboarding_project/core/app_export.dart';
import '../../chat.dart';
import '../../../profile/profile.dart';

class SelectUserPage extends StatefulWidget {
  const SelectUserPage({super.key});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  late SelectUserViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SelectUserViewModel(
      profileDataSource: ProfileRemoteDataSourceImpl(),
      chatRepository: ChatRepositoryImpl(
        remoteDataSource: ChatRemoteDataSourceImpl(),
      ),
    );
    _viewModel.loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _viewModel.updateSearchQuery(query);
  }

  Future<void> _startChat(String userId) async {
    if (_isNavigating) {
      debugPrint('⚠️ Already navigating, ignoring tap');
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      final room = await _viewModel.createChatWithUser(userId);

      if (mounted && room != null) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              roomId: room.id,
              roomName: room.displayName,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isDark = false;
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : appTheme.white_A700,
        appBar: AppBar(
          title: Text(
            'Select User',
            style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: Consumer<SelectUserViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.searchQuery.isNotEmpty) {
                        return IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            viewModel.clearSearch();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            
            // User list
            Expanded(
              child: Stack(
                children: [
                  Consumer<SelectUserViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(color: appTheme.blue_900),
                        );
                      }

                      if (viewModel.status == SelectUserStatus.error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.errorMessage ?? 'Failed to load users',
                                style: TextStyleHelper.instance.body15MediumInter.copyWith(
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.loadUsers(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.blue_900,
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }

                      if (viewModel.users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                viewModel.searchQuery.isEmpty 
                                  ? Icons.people_outline 
                                  : Icons.search_off,
                                size: 64,
                                color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.searchQuery.isEmpty 
                                  ? 'No users found' 
                                  : 'No users match "${viewModel.searchQuery}"',
                                style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                  color: isDark ? Colors.white : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: viewModel.users.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
                        ),
                        itemBuilder: (context, index) {
                          final user = viewModel.users[index];
                          return ListTile(
                            tileColor: isDark ? const Color(0xFF121212) : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
                              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        user.avatarUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 32,
                                            color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Icon(
                                            Icons.person,
                                            size: 32,
                                            color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 32,
                                      color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                    ),
                            ),
                            title: Text(
                              user.name,
                              style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                fontSize: 16,
                                color: isDark ? Colors.white : null,
                              ),
                            ),
                            subtitle: user.bio != null
                                ? Text(
                                    user.bio!,
                                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                                      color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: _isNavigating ? null : () => _startChat(user.id),
                          );
                        },
                      );
                    },
                  ),

                  // Loading overlay
                  if (_isNavigating)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Card(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: appTheme.blue_900),
                                const SizedBox(height: 16),
                                Text(
                                  'Starting chat...',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}