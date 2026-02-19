// --- Before barrel file ----

// lib/features/auth/viewmodels/auth_viewmodel.dart
// import 'package:flutter/material.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../../../core/app_export.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/routes/app_routes.dart';

// --- After barrel file ----
// There is less import 
// --------------------------
import 'package:onboarding_project/core/app_export.dart';
import '../../auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthModel loginModel = const AuthModel();

  // Login Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Register Controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isSuccess = false;

  bool get isLoggedIn => loginModel.isLoggedIn;

  String? emailError;
  String? passwordError;
  String? usernameError;
  String? confirmPasswordError;
  
  // Gender selection
  String? selectedGender;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void initialize() {
    isLoading = false;
    isSuccess = false;
    emailError = null;
    passwordError = null;
    usernameError = null;
    confirmPasswordError = null;
    notifyListeners();
  }

  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  // Validators
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
      passwordError = 'Password must be at least 6 characters (any format)';
      return passwordError;
    }
    passwordError = null;
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      usernameError = 'Username is required';
      return usernameError;
    }
    if (value.length < 3) {
      usernameError = 'Username must be at least 3 characters';
      return usernameError;
    }
    usernameError = null;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
      return confirmPasswordError;
    }
    if (value != registerPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      return confirmPasswordError;
    }
    confirmPasswordError = null;
    return null;
  }

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
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

  void updateUsernameError() {
    validateUsername(usernameController.text);
    notifyListeners();
  }

  void updateConfirmPasswordError() {
    validateConfirmPassword(confirmPasswordController.text);
    notifyListeners();
  }

  void resetRegisterFields() {
    firstNameController.clear();
    lastNameController.clear();
    usernameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    confirmPasswordController.clear();
    selectedGender = 'Male'; // Or whatever your default is
    notifyListeners(); // Refresh UI if necessary
  }

  // Login
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
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.user != null) {
        // This is the old approach with modify the field since it was mutable 
        // loginModel.email = emailController.text;
        // loginModel.isLoggedIn = true;
        // loginModel.username = response.user?.userMetadata?['username'] ?? '';

          loginModel = AuthModel(
          email: emailController.text,
          isLoggedIn: true,
          username: response.user?.userMetadata?['username'] ?? '',
          password: passwordController.text, 
       
        );
        isSuccess = true;

        if (context.mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Login successful!'),
          //     backgroundColor: appTheme.greenCustom,
          //   ),
          // );

          emailController.clear();
          passwordController.clear();

          context.go(AppPaths.feed);
        }
      }
    } catch (e) {
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

  // Register
  Future<void> onRegisterPressed(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      print('🔐 Starting registration...');
      
      final response = await _authRepository.register(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text,
        username: usernameController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: selectedGender,
      );

      if (response.user != null) {
        // await _authRepository.logout();
        isSuccess = true;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful! Welcome!'),
              backgroundColor: appTheme.greenCustom,
            ),
          );

          // Clear all fields
          firstNameController.clear();
          lastNameController.clear();
          usernameController.clear();
          registerEmailController.clear();
          registerPasswordController.clear();
          confirmPasswordController.clear();
          selectedGender = null;

          // Navigate to main screen (feed)
          context.go(AppPaths.feed);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSignUpPressed(BuildContext context) {
    context.go(AppPaths.register);
  }

  void onSignInPressed(BuildContext context) {
    context.go(AppPaths.login);
  }

  void logout() {
    loginModel = const AuthModel(); // Reset to default
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}