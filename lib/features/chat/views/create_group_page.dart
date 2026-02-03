// lib/features/chat/views/create_group_page.dart

import 'package:flutter/material.dart';
import 'package:onboarding_project/features/chat/viewmodels/your_group_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_edit_text.dart';
import 'group_chat_success.dart';
import '../viewmodels/create_group_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
  // I update to use multiprovider here because we need to use loadgroup from your_group_viewmodel
  // so it will automatically reload the list of group when navigate from the success screen
    return ChangeNotifierProvider(
      create: (_) => CreateGroupViewModel(
        repository: ChatRepositoryImpl(
          remoteDataSource: ChatRemoteDataSourceImpl(),
        ),
      ),
      child: const _CreateGroupPageContent(),
    );
  }
  // return MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(
  //         create: (_) => CreateGroupViewModel(
  //           repository: ChatRepositoryImpl(
  //             remoteDataSource: ChatRemoteDataSourceImpl(),
  //           ),
  //         ),
  //       ),
  //       ChangeNotifierProvider(
  //         create: (_) => YourGroupsViewModel(
  //           repository: ChatRepositoryImpl(
  //             remoteDataSource: ChatRemoteDataSourceImpl(),
  //           ),
  //         ),
  //       ),
  //     ],
  //     child: const _CreateGroupPageContent(),
  //   );
  // }
}

class _CreateGroupPageContent extends StatefulWidget {
  const _CreateGroupPageContent();

  @override
  State<_CreateGroupPageContent> createState() => _CreateGroupPageContentState();
}

class _CreateGroupPageContentState extends State<_CreateGroupPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<CreateGroupViewModel>();
    final groupName = _groupNameController.text.trim();

    final success = await viewModel.createGroup(groupName);

    if (!mounted) return;

    if (success && viewModel.createdGroup != null) {
      
      // Reload groups list
      // final yourGroupsViewModel = context.read<YourGroupsViewModel>();
      // await yourGroupsViewModel.loadGroups();
      // print('Groups loaded: ${yourGroupsViewModel.groups.length}');
      // print('Groups: ${yourGroupsViewModel.groups}');

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatSuccess(
            groupCode: viewModel.createdGroup!.inviteCode,
            groupName: groupName,
          ),
        ),
      );
      
     
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to create group'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        backgroundColor: appTheme.white_A700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black_900),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Create group',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            color: appTheme.blue_900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<CreateGroupViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      
                      // Group name label
                      Text(
                        'Group name',
                        style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appTheme.black_900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Group name input field
                      CustomEditText(
                        controller: _groupNameController,
                        placeholder: 'name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          if (value.length < 3) {
                            return 'Group name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      
                      // Create button
                      Center(
                        child: CustomButton(
                          text: viewModel.isLoading ? 'Creating...' : 'create',
                          width: 200,
                          backgroundColor: appTheme.blue_900,
                          textColor: appTheme.white_A700,
                          borderRadius: 28,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          onPressed: viewModel.isLoading ? null : _handleCreateGroup,
                          isEnabled: !viewModel.isLoading,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // Illustration image
                      Center(
                        child: Image.asset(
                          ImageConstant.imgCreateGroup,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}