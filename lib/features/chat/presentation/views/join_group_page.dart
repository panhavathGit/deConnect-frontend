// lib/features/chat/views/join_group_page.dart

import 'package:onboarding_project/core/app_export.dart';
import '../../chat.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  final _repository = ChatRepositoryImpl(
    remoteDataSource: ChatRemoteDataSourceImpl(),
  );
  bool _isJoining = false;

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    try {
      final joinCode = _joinCodeController.text.trim();
      
      // Call backend to join group
      final response = await _repository.joinGroupByCode(joinCode);
      
      if (!mounted) return;

      if (response.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: appTheme.greenCustom ?? Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to chat list (pop twice to get back to chat list)
        Navigator.pop(context);
        
        // Optional: Show another success message on the chat list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined "${response.roomName ?? 'group'}" successfully!'),
              backgroundColor: appTheme.greenCustom ?? Colors.green,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  // Optionally navigate to the group chat
                  if (response.roomId != null) {
                    // You can implement navigation to the chat room here if needed
                  }
                },
              ),
            ),
          );
        }
      } else {
        // Show error message
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isJoining = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join group: ${e.toString()}'),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Icon
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: appTheme.blue_gray_100.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.tag,
                        size: 80,
                        color: appTheme.black_900.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    'Join a team with a code',
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: appTheme.black_900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // Join code input field
                  TextFormField(
                    controller: _joinCodeController,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter join code.',
                      hintStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
                        color: appTheme.greyCustom.withOpacity(0.5),
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: appTheme.white_A700,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appTheme.greyCustom.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appTheme.greyCustom.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appTheme.blue_900,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a join code';
                      }
                      if (value.length < 6) {
                        return 'Join code must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 100),
                  
                  // Illustration image (if available)
                  if (ImageConstant.imgJoinGroup.isNotEmpty)
                    Center(
                      child: Image.asset(
                        ImageConstant.imgJoinGroup,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomButton(
          text: _isJoining ? 'Joining...' : 'Join',
          width: double.infinity,
          backgroundColor: appTheme.blue_900,
          textColor: appTheme.white_A700,
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(vertical: 16),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          onPressed: _isJoining ? null : _handleJoinGroup,
          isEnabled: !_isJoining,
        ),
      ),
    );
  }
}