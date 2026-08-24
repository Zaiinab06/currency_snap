import 'package:flutter/material.dart';
import '../presentation/navigation/app_bottom_nav.dart';
import '../presentation/screens/splash/splash_screen.dart';

/// Central routing configuration for named route navigation.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String main = '/main';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const AppBottomNav());
      default:
        return MaterialPageRoute(builder: (_) => const AppBottomNav());
    }
  }
}
