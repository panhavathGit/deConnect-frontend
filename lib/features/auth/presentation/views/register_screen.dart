// lib/features/auth/views/register_screen.dart
import 'package:onboarding_project/core/app_export.dart';
import '../../auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (context) => AuthViewModel(),
      child: const RegisterScreen(),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final _formKeyStepOne = GlobalKey<FormState>();
  final _formKeyStepTwo = GlobalKey<FormState>();
  int _currentStep = 0;

  void _nextPage() {
    if (_currentStep == 0) {
      if (_formKeyStepOne.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: Consumer<AuthViewModel>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int page) => setState(() => _currentStep = page),
                    children: [
                      _buildStepOne(provider),
                      _buildStepTwo(provider),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepOne(AuthViewModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
      child: Form(
        key: _formKeyStepOne,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildProgressBar(step: 1),
            const SizedBox(height: 30),
            
            // First Name
            Text(
              'First Name',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'First name',
              controller: provider.firstNameController,
              validator: (value) => provider.validateName(value, 'First name'),
            ),
            const SizedBox(height: 16),
            
            // Last Name
            Text(
              'Last Name',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'Last name',
              controller: provider.lastNameController,
              validator: (value) => provider.validateName(value, 'Last name'),
            ),
            const SizedBox(height: 16),
            
            // Gender
            Text(
              'Gender',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: provider.selectedGender,
                  onChanged: (value) => provider.setGender(value!),
                  activeColor: appTheme.blue_900,
                ),
                const Text('Male'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'Female',
                  groupValue: provider.selectedGender,
                  onChanged: (value) => provider.setGender(value!),
                  activeColor: appTheme.blue_900,
                ),
                const Text('Female'),
              ],
            ),
            const SizedBox(height: 10),
            
            CustomButton(
              text: 'Next',
              width: double.infinity,
              backgroundColor: appTheme.blue_900,
              textColor: appTheme.white_A700,
              borderRadius: 28,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              onPressed: _nextPage,
            ),
            const SizedBox(height: 20),
            
            Center(
              child: GestureDetector(
                onTap: () => provider.onSignInPressed(context),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyleHelper.instance.title18RegularSourceSerifPro,
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyleHelper.instance.title18RegularSourceSerifPro.copyWith(
                          color: appTheme.amber_500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(AuthViewModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
      child: Form(
        key: _formKeyStepTwo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildHeader(),
            _buildProgressBar(step: 2),
            const SizedBox(height: 30),
            
            // Username
            Text(
              'Username',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'Username',
              controller: provider.usernameController,
              validator: provider.validateUsername,
              onChanged: (value) => provider.updateUsernameError(),
            ),
            const SizedBox(height: 16),
            
            // Email
            Text(
              'Email Address',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.email,
              placeholder: 'Email',
              controller: provider.registerEmailController,
              validator: provider.validateEmail,
              onChanged: (value) => provider.updateEmailError(),
            ),
            const SizedBox(height: 16),
            
            // Password
            Text(
              'Password',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.password,
              placeholder: 'Password',
              controller: provider.registerPasswordController,
              validator: provider.validatePassword,
              onChanged: (value) => provider.updatePasswordError(),
            ),
            const SizedBox(height: 16),
            
            // Confirm Password
            Text(
              'Confirm Password',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            const SizedBox(height: 6),
            CustomEditText(
              inputType: CustomInputType.password,
              placeholder: 'Confirm password',
              controller: provider.confirmPasswordController,
              validator: provider.validateConfirmPassword,
              onChanged: (value) => provider.updateConfirmPasswordError(),
            ),
            const SizedBox(height: 30),
            
            CustomButton(
              text: provider.isLoading ? 'Registering...' : 'Register',
              width: double.infinity,
              backgroundColor: appTheme.blue_900,
              textColor: appTheme.white_A700,
              borderRadius: 28,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              onPressed: provider.isLoading
                  ? null
                  : () => provider.onRegisterPressed(context, _formKeyStepTwo),
            ),
            const SizedBox(height: 20),
            
            Center(
              child: TextButton(
                onPressed: _previousPage,
                child: Text(
                  'Back',
                  style: TextStyleHelper.instance.title18RegularSourceSerifPro.copyWith(
                    color: appTheme.amber_500,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Register',
          style: TextStyleHelper.instance.display40RegularSourceSerifPro,
        ),
        const SizedBox(height: 5),
        Text(
          'start connecting with DeConnect',
          style: TextStyleHelper.instance.title18RegularSourceSerifPro,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProgressBar({required int step}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: appTheme.greenCustom,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: step == 2 ? appTheme.greenCustom : appTheme.blue_gray_100,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          CustomImageView(
            imagePath: ImageConstant.img3dIllustration,
            width: 152,
            height: 102,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          Text(
            'created by',
            style: TextStyleHelper.instance.title16RegularSourceSerifPro,
          ),
          const SizedBox(height: 8),
          CustomImageView(
            imagePath: ImageConstant.imgDelightechLogo,
            width: 134,
            height: 44,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}