import 'package:flutter/cupertino.dart';
import '../presentation/navigation/app_bottom_nav.dart';
import '../presentation/screens/splash/splash_screen.dart';

/// Central routing configuration for named route navigation using iOS CupertinoPageRoutes.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String main = '/main';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());
      case main:
        return CupertinoPageRoute(builder: (_) => const AppBottomNav());
      default:
        return CupertinoPageRoute(builder: (_) => const AppBottomNav());
    }
  }
}
