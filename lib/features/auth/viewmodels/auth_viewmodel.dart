import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

// class AuthViewModel extends ChangeNotifier {
//   final AuthRepository _repo = AuthRepository();
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<void> login(String email, String password, BuildContext context) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _repo.login(email, password);
//       // Navigation is handled in main.dart via Auth State changes, 
//       // or you can return true here to let View handle navigation.
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }

import '../../../core/app_export.dart';
class AuthViewModel extends ChangeNotifier{
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

    // Simulate login process
    await Future.delayed(Duration(seconds: 2));

    // Update login model
    loginModel.email = emailController.text;
    loginModel.password = passwordController.text;
    loginModel.isLoggedIn = true;

    isLoading = false;
    isSuccess = true;
    notifyListeners();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login successful!'),
        backgroundColor: appTheme.greenCustom,
      ),
    );

    // Clear form
    emailController.clear();
    passwordController.clear();

    // Navigate to the next screen (based on navigateTo: "18:575")
    // Since no specific route is provided, we'll simulate navigation
    await Future.delayed(Duration(milliseconds: 500));

    // Reset success state
    isSuccess = false;
    notifyListeners();
  }

  void onSignUpPressed() {
    // Navigate to sign up screen
    // Implementation would depend on available routes
    print('Navigate to Sign Up screen');
  }
}

