// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(AssetImage(ImageConstant.imgDelightechLogo), context);
      precacheImage(AssetImage(ImageConstant.img3dIllustration), context);
    });

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Navigate after delay
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = SupabaseService.client.auth.currentUser != null;

    if (isLoggedIn) {
      context.go(AppPaths.feed);
    } else {
      context.go(AppPaths.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated illustration
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    ImageConstant.img3dIllustration,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Animated Khmer text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'ដឺ ខនណិច',
                  style: TextStyleHelper.instance.display40RegularSourceSerifPro
                      .copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: appTheme.black_900,
                      ),
                ),
              ),

              const SizedBox(height: 16),

              // Animated app name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'DeConnect',
                  style: TextStyleHelper.instance.display40RegularSourceSerifPro
                      .copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: appTheme.blue_900,
                      ),
                ),
              ),

              const Spacer(),

              // Created by section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'created by',
                      style: TextStyleHelper.instance.body15MediumInter
                          .copyWith(color: appTheme.greyCustom, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 200,
                      height: 100, // Set a fixed height for the logo space
                      child: Image.asset(
                        ImageConstant.imgDelightechLogoSplash,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
