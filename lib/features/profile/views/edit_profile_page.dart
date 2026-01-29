// lib/features/profile/views/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/app_export.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_edit_text.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/data/models/user_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:go_router/go_router.dart';

// class EditProfilePage extends StatefulWidget {
//   final User user;

//   const EditProfilePage({super.key, required this.user});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

class EditProfilePage extends StatefulWidget {
  final User user;
  final ProfileViewModel viewModel;

  const EditProfilePage({
    super.key, 
    required this.user,
    required this.viewModel,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  
  File? _selectedImage;
  String? _avatarUrl;
  String? _selectedGender;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.name);
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _avatarUrl = widget.user.avatarUrl;
    _selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return _avatarUrl;

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp.jpg';
      final filePath = 'avatars/$fileName';

      // Delete old avatar if exists
      if (_avatarUrl != null && _avatarUrl!.contains('avatars/')) {
        try {
          final oldPath = _avatarUrl!.split('avatars/').last.split('?').first;
          await SupabaseService.client.storage
              .from('avatars')
              .remove(['avatars/$oldPath']);
        } catch (e) {
          print('Failed to delete old avatar: $e');
        }
      }

      // Upload new avatar
      await SupabaseService.client.storage
          .from('avatars')
          .upload(filePath, _selectedImage!);

      final url = SupabaseService.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      print('Error uploading avatar: $e');
      throw Exception('Failed to upload avatar');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload avatar if changed
      final avatarUrl = await _uploadAvatar();

      // Create updated user object
      final updatedUser = User(
        id: widget.user.id,
        name: _usernameController.text.trim(),
        email: widget.user.email,
        firstName: _firstNameController.text.trim().isEmpty 
            ? null 
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty 
            ? null 
            : _lastNameController.text.trim(),
        gender: _selectedGender,
        avatarUrl: avatarUrl,
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        createdAt: widget.user.createdAt,
      );

      // Update via ViewModel
      if (mounted) {
        // final viewModel = context.read<ProfileViewModel>();
        // await viewModel.updateProfile(updatedUser);
        await widget.viewModel.updateProfile(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: appTheme.greenCustom,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appTheme.blue_gray_100,
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _avatarUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        size: 60,
                                        color: appTheme.greyCustom,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: appTheme.greyCustom,
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appTheme.blue_900,
                              border: Border.all(
                                color: appTheme.white_A700,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: appTheme.white_A700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Username
                Text(
                  'Username',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 6),
                CustomEditText(
                  inputType: CustomInputType.text,
                  placeholder: 'Your username',
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // First Name
                Text(
                  'First Name',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 6),
                CustomEditText(
                  inputType: CustomInputType.text,
                  placeholder: 'Your first name',
                  controller: _firstNameController,
                ),
                SizedBox(height: 16),

                // Last Name
                Text(
                  'Last Name',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 6),
                CustomEditText(
                  inputType: CustomInputType.text,
                  placeholder: 'Your last name',
                  controller: _lastNameController,
                ),
                SizedBox(height: 16),

                // Gender
                Text(
                  'Gender',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: appTheme.grey100,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: appTheme.blue_gray_100),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      hint: Text('Select gender'),
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Bio
                Text(
                  'Bio',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: appTheme.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: appTheme.blue_gray_100),
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 160,
                    decoration: InputDecoration(
                      hintText: 'Tell us about yourself...',
                      border: InputBorder.none,
                      hintStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
                        color: appTheme.greyCustom,
                      ),
                    ),
                    style: TextStyleHelper.instance.body15MediumInter,
                  ),
                ),
                SizedBox(height: 30),

                // Save Button
                CustomButton(
                  text: _isLoading ? 'Saving...' : 'Save Changes',
                  width: double.infinity,
                  backgroundColor: appTheme.blue_900,
                  textColor: appTheme.white_A700,
                  borderRadius: 28,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  onPressed: _isLoading ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}