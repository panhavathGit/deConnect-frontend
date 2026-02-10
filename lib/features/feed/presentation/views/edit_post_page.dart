// lib/features/feed/presentation/views/edit_post_page.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:onboarding_project/core/app_export.dart';
import '../../feed.dart';
import '../../../profile/profile.dart';

class EditPostPage extends StatefulWidget {
  final FeedPost post;
  final ProfileViewModel viewModel;

  const EditPostPage({
    super.key,
    required this.post,
    required this.viewModel,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final ImagePicker _picker = ImagePicker();
  
  File? _newImage;
  late List<String> _selectedTags;
  bool _isLoading = false;
  String? _imageUrl;

  final List<String> _availableTags = [
    'General',
    'Politics',
    'Technologies',
    'Business',
    'Entertainment',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedTags = List.from(widget.post.tags);
    _imageUrl = widget.post.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _newImage = File(image.path);
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: appTheme.blue_900),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: appTheme.blue_900),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_newImage != null || _imageUrl != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _newImage = null;
                    _imageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _imageUrl;

      // Upload new image if selected
      if (_newImage != null) {
        finalImageUrl = await _uploadImage(_newImage!);
      }

      final updatedPost = FeedPost(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        userId: widget.post.userId,
        imageUrl: finalImageUrl,
        authorName: widget.post.authorName,
        authorAvatar: widget.post.authorAvatar,
        tags: _selectedTags,
        createdAt: widget.post.createdAt,
      );

      final success = await widget.viewModel.updatePost(updatedPost);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post updated successfully!'),
              backgroundColor: appTheme.greenCustom,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update post'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_$timestamp.jpg';
      final filePath = 'posts/$fileName';

      await SupabaseService.client.storage
          .from('post-images')
          .upload(filePath, image);

      final imageUrl = SupabaseService.client.storage
          .from('post-images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
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
          'Edit Post',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Selection
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: appTheme.blue_gray_100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appTheme.blue_900.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _newImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _newImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CustomImageView(
                                  imagePath: _imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: appTheme.greyCustom,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                                      color: appTheme.greyCustom,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                SizedBox(height: 20),

                // Tags Selection
                Text(
                  'Tags',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => _toggleTag(tag),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? appTheme.blue_900 : appTheme.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyleHelper.instance.body15MediumInter.copyWith(
                            color: isSelected ? appTheme.white_A700 : appTheme.black_900,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  'Title',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 8),
                CustomEditText(
                  controller: _titleController,
                  placeholder: 'Enter post title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Content
                Text(
                  'Content',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Write your post content here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content is required';
                    }
                    if (value.length < 10) {
                      return 'Content must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Update Button
                CustomButton(
                  text: _isLoading ? 'Updating...' : 'Update Post',
                  width: double.infinity,
                  backgroundColor: appTheme.blue_900,
                  textColor: appTheme.white_A700,
                  borderRadius: 28,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  onPressed: _isLoading ? null : _updatePost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}