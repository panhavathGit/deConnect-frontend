// lib/features/feed/presentation/views/create_post_page.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:onboarding_project/core/app_export.dart';
import '../../feed.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePostViewModel(),
      child: const CreatePostPage(),
    );
  }

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableTags = [
    'General',
    'Politics',
    'Technologies',
    'Business',
    'Entertainment',
    'Sports',
  ];

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
        context.read<CreatePostViewModel>().setImage(File(image.path));
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
    final viewModel = context.read<CreatePostViewModel>();
    
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
            if (viewModel.selectedImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<CreatePostViewModel>();
    final success = await viewModel.createPost(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: appTheme.greenCustom,
          ),
        );
        
        // re-load post on feed page, so it get new post as soon as new post added
        context.read<FeedViewModel>().loadPosts();

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${viewModel.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
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
          'Create Post',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro,
        ),
      ),
      body: SafeArea(
        child: Consumer<CreatePostViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
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
                        child: viewModel.selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  viewModel.selectedImage!,
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
                        final isSelected = viewModel.selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => viewModel.toggleTag(tag),
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

                    // Create Button
                    CustomButton(
                      text: viewModel.isLoading ? 'Creating...' : 'Create Post',
                      width: double.infinity,
                      backgroundColor: appTheme.blue_900,
                      textColor: appTheme.white_A700,
                      borderRadius: 28,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      onPressed: viewModel.isLoading ? null : _createPost,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

    
}