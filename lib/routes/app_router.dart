import 'package:flutter/cupertino.dart';
import '../features/converter/presentation/screens/splash_screen.dart';
import '../features/navigation/presentation/app_bottom_nav.dart';
import '../features/onboarding/presentation/screens/onboarding_name_screen.dart';

/// Central routing configuration for named route navigation using iOS CupertinoPageRoutes.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return CupertinoPageRoute(builder: (_) => const OnboardingNameScreen());
      case main:
        return CupertinoPageRoute(builder: (_) => const AppBottomNav());
      default:
        return CupertinoPageRoute(builder: (_) => const AppBottomNav());
    }
  }
}
