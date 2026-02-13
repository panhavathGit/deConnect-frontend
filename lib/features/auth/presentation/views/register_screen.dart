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
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      backgroundColor: appTheme.white_A700,
      body: Consumer<AuthViewModel>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(), 
                        onPageChanged: (int page) => setState(() => _currentStep = page),
                        children: [
                          _buildStepOne(provider, isKeyboardVisible),
                          _buildStepTwo(provider, isKeyboardVisible),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Footer: Hidden when keyboard is up to keep it clean
                if (!isKeyboardVisible)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildFooter(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepOne(AuthViewModel provider, bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Form(
        key: _formKeyStepOne,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(isKeyboardVisible),
            _buildProgressBar(step: 1),
            SizedBox(height: isKeyboardVisible ? 10 : 30),
            
            _buildLabel('First Name'),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'First name',
              controller: provider.firstNameController,
              validator: (value) => provider.validateName(value, 'First name'),
            ),
            SizedBox(height: isKeyboardVisible ? 8 : 16),
            
            _buildLabel('Last Name'),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'Last name',
              controller: provider.lastNameController,
              validator: (value) => provider.validateName(value, 'Last name'),
            ),
            
            const SizedBox(height: 10),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: provider.selectedGender,
                  onChanged: (value) => provider.setGender(value!),
                  activeColor: appTheme.blue_900,
                ),
                const Text('Male'),
                const SizedBox(width: 10),
                Radio<String>(
                  value: 'Female',
                  groupValue: provider.selectedGender,
                  onChanged: (value) => provider.setGender(value!),
                  activeColor: appTheme.blue_900,
                ),
                const Text('Female'),
              ],
            ),
            
            CustomButton(
              text: 'Next',
              width: double.infinity,
              backgroundColor: appTheme.blue_900,
              textColor: appTheme.white_A700,
              borderRadius: 28,
              onPressed: _nextPage,
            ),

            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  // --- CLEAR STATE APPROACH ---
                  // 1. Reset all fields in the ViewModel
                  provider.resetRegisterFields(); 
                  // 2. Navigate away
                  provider.onSignInPressed(context);
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyleHelper.instance.title18RegularSourceSerifPro.copyWith(fontSize: 16),
                    children: [
                      const TextSpan(text: "Already have an account? ", style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(color: appTheme.amber_500, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 150), 
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(AuthViewModel provider, bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Form(
        key: _formKeyStepTwo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(isKeyboardVisible),
            _buildProgressBar(step: 2),
            SizedBox(height: isKeyboardVisible ? 10 : 20),
            
            _buildLabel('Username'),
            CustomEditText(
              inputType: CustomInputType.text,
              placeholder: 'Username',
              controller: provider.usernameController,
              validator: provider.validateUsername,
            ),
            SizedBox(height: isKeyboardVisible ? 6 : 10),
            
            _buildLabel('Email Address'),
            CustomEditText(
              inputType: CustomInputType.email,
              placeholder: 'Email',
              controller: provider.registerEmailController,
              validator: provider.validateEmail,
            ),
            SizedBox(height: isKeyboardVisible ? 6 : 10),
            
            _buildLabel('Password'),
            CustomEditText(
              inputType: CustomInputType.password,
              placeholder: 'Password',
              controller: provider.registerPasswordController,
              validator: provider.validatePassword,
            ),
            SizedBox(height: isKeyboardVisible ? 6 : 10),
            
            _buildLabel('Confirm Password'),
            CustomEditText(
              inputType: CustomInputType.password,
              placeholder: 'Confirm password',
              controller: provider.confirmPasswordController,
              validator: provider.validateConfirmPassword,
            ),
            
            // const Spacer(),

            CustomButton(
              text: provider.isLoading ? 'Registering...' : 'Register',
              width: double.infinity,
              backgroundColor: appTheme.blue_900,
              textColor: appTheme.white_A700,
              borderRadius: 28,
              onPressed: provider.isLoading
                  ? null
                  : () => provider.onRegisterPressed(context, _formKeyStepTwo),
            ),
          
            Center(
              child: TextButton(
                onPressed: _previousPage,
                child: Text(
                  'Back to Previous Step',
                  style: TextStyle(color: appTheme.amber_500, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(fontSize: 16)),
    );
  }

  Widget _buildHeader(bool isKeyboardVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Register',
          style: TextStyleHelper.instance.display40RegularSourceSerifPro.copyWith(
            fontSize: isKeyboardVisible ? 28 : 36, 
          ),
        ),
        if (!isKeyboardVisible) 
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'start connecting with DeConnect',
              style: TextStyleHelper.instance.title18RegularSourceSerifPro.copyWith(fontSize: 16),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProgressBar({required int step}) {
    return Row(
      children: [
        Expanded(child: Container(height: 6, decoration: BoxDecoration(color: appTheme.greenCustom, borderRadius: BorderRadius.circular(10)))),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 6, decoration: BoxDecoration(color: step == 2 ? appTheme.greenCustom : appTheme.blue_gray_100, borderRadius: BorderRadius.circular(10)))),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImageView(
          imagePath: ImageConstant.img3dIllustration,
          width: 100,
          height: 70,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 8),
        Text('created by', style: TextStyleHelper.instance.title16RegularSourceSerifPro.copyWith(fontSize: 14)),
        const SizedBox(height: 4),
        CustomImageView(
          imagePath: ImageConstant.imgDelightechLogo,
          width: 100,
          height: 32,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}