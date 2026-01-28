import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/app_export.dart';
import 'package:go_router/go_router.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthModel loginModel = AuthModel();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isSuccess = false;
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void initialize() {
    isLoading = false;
    isSuccess = false;
    emailError = null;
    passwordError = null;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      emailError = 'Email is required';
      return emailError;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      emailError = 'Enter a valid email';
      return emailError;
    }
    emailError = null;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      passwordError = 'Password is required';
      return passwordError;
    }
    if (value.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      return passwordError;
    }
    passwordError = null;
    return null;
  }

  void updateEmailError() {
    validateEmail(emailController.text);
    notifyListeners();
  }

  void updatePasswordError() {
    validatePassword(passwordController.text);
    notifyListeners();
  }

  Future<void> onLoginPressed(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Call Supabase login
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.user != null) {
        // Update login model
        loginModel.email = emailController.text;
        loginModel.isLoggedIn = true;
        loginModel.username = response.user?.userMetadata?['username'] ?? '';

        isSuccess = true;

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful!'),
              backgroundColor: appTheme.greenCustom,
            ),
          );

          // Clear form
          emailController.clear();
          passwordController.clear();

          // Navigate to main feed
          context.go('/main');
        }
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSignUpPressed() {
    // Navigate to sign up screen
    // Implementation would depend on available routes
    print('Navigate to Sign Up screen');
  }
}