import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../navigation/presentation/app_bottom_nav.dart';
import '../../../onboarding/presentation/screens/onboarding_name_screen.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

/// Splash screen displaying light theme branding with automatic routing to Onboarding or Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: 1200), _checkNavigation);
  }

  void _checkNavigation() {
    if (!mounted) return;
    final settingsState = context.read<SettingsCubit>().state;
    final userName = settingsState.userDisplayName.trim();

    final targetWidget = userName.isNotEmpty
        ? const AppBottomNav()
        : const OnboardingNameScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Brand Logo Container (72x72, borderRadius: 20, Pink-to-Purple Gradient)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEC4899),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.arrow_right_arrow_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Title
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Tagline / Description
              const Text(
                'Smart, fast & real-time currency conversion at your fingertips.',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.4,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 36),

              // Subtle Loading Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
