// lib/features/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_edit_text.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (context) => AuthViewModel(),
      child: LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: SafeArea(  // Added SafeArea
        child: Consumer<AuthViewModel>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(top: 24, left: 18, right: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login',
                        style: TextStyleHelper
                            .instance
                            .display40RegularSourceSerifPro,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'start connecting with DeConnect',
                        style:
                            TextStyleHelper.instance.title18RegularSourceSerifPro,
                      ),
                      SizedBox(height: 58),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: TextStyleHelper
                                .instance
                                .title18BoldSourceSerifPro,
                          ),
                          SizedBox(height: 6),
                          CustomEditText(
                            inputType: CustomInputType.email,
                            placeholder: 'Your Email',
                            controller: provider.emailController,
                            validator: provider.validateEmail,
                            onChanged: (value) {
                              provider.updateEmailError();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyleHelper
                                .instance
                                .title18BoldSourceSerifPro,
                          ),
                          SizedBox(height: 6),
                          CustomEditText(
                            inputType: CustomInputType.password,
                            placeholder: 'Your Password',
                            controller: provider.passwordController,
                            validator: provider.validatePassword,
                            onChanged: (value) {
                              provider.updatePasswordError();
                            },
                          ),
                        ],
                      ),
                      CustomButton(
                        text: provider.isLoading ? 'Loading...' : 'Login',
                        width: double.infinity,
                        backgroundColor: appTheme.blue_900,
                        textColor: appTheme.white_A700,
                        borderRadius: 28,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 30,
                        ),
                        margin: EdgeInsets.only(top: 68),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                provider.onLoginPressed(context, _formKey);
                              },
                      ),
                      SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account yet?",
                            style: TextStyleHelper
                                .instance
                                .title18RegularSourceSerifPro,
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              provider.onSignUpPressed(context);
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyleHelper
                                  .instance
                                  .title18RegularSourceSerifPro
                                  .copyWith(color: appTheme.amber_500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 100),
                      Center(
                        child: CustomImageView(
                          imagePath: ImageConstant.img3dIllustration,
                          width: 152,
                          height: 102,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'created by',
                          style: TextStyleHelper
                              .instance
                              .title16RegularSourceSerifPro,
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: CustomImageView(
                          imagePath: ImageConstant.imgDelightechLogo,
                          width: 134,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16),
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