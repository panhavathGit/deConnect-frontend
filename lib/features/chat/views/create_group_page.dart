import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_edit_text.dart';
import 'group_chat_success.dart';
import 'dart:math';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  String _generateGroupCode() {
    // Generate a random 8-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _handleCreateGroup() {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text.trim();
      final groupCode = _generateGroupCode();
      
      print('Creating group: $groupName with code: $groupCode');
      
      // TODO: Call your backend API to create the group
      // await chatRepository.createGroup(groupName, groupCode);
      
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatSuccess(
            groupCode: groupCode,
            groupName: groupName,
          ),
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
        child: SingleChildScrollView(
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
                      text: 'create',
                      width: 200,
                      backgroundColor: appTheme.blue_900,
                      textColor: appTheme.white_A700,
                      borderRadius: 28,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      onPressed: _handleCreateGroup,
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
        ),
      ),
    );
  }
}