import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  runApp(const CurrencySnapApp());
}

class CurrencySnapApp extends StatelessWidget {
  const CurrencySnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // TODO: replace with SplashScreen -> HomeScreen navigation flow
      // once app_router.dart and the Home/Converter screen are built.
      home: const SplashScreen(),
    );
  }
}
