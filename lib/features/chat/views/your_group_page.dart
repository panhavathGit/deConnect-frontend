// lib/features/chat/views/your_groups_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../viewmodels/your_group_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';
import 'chat_room_page.dart';

class YourGroupsPage extends StatelessWidget {
  const YourGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => YourGroupsViewModel(
        repository: ChatRepositoryImpl(
          remoteDataSource: ChatRemoteDataSourceImpl(),
        ),
      )..loadGroups(),
      child: const _YourGroupsPageContent(),
    );
  }
}

class _YourGroupsPageContent extends StatelessWidget {
  const _YourGroupsPageContent();

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copied: $code'),
        backgroundColor: appTheme.greenCustom ?? Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        title: Text(
          'Your Groups',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: appTheme.blue_900,
        foregroundColor: Colors.white,
      ),
      body: Consumer<YourGroupsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.blue_900),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyleHelper.instance.body15MediumInter,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 64, color: appTheme.greyCustom),
                  const SizedBox(height: 16),
                  Text(
                    'No groups yet',
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create or join a group to get started!',
                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                      color: appTheme.greyCustom,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadGroups(),
            color: appTheme.blue_900,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = viewModel.groups[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            roomId: group.roomId,
                            roomName: group.roomName,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: appTheme.blue_900.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.group,
                                  color: appTheme.blue_900,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.roomName,
                                      style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${group.memberCount} member${group.memberCount != 1 ? 's' : ''}',
                                      style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                                        color: appTheme.greyCustom,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (group.isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appTheme.blue_900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (group.isAdmin && group.inviteCode.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invite Code',
                                        style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                                          color: appTheme.greyCustom,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        group.inviteCode,
                                        style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                          fontSize: 18,
                                          color: appTheme.blue_900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () => _copyCode(context, group.inviteCode),
                                  color: appTheme.blue_900,
                                  tooltip: 'Copy code',
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}