import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/setting_screen.dart';

/// Main navigation container preserving tab states via an IndexedStack.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_rounded),
            selectedIcon: Icon(
              Icons.currency_exchange_rounded,
              color: AppColors.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            selectedIcon: Icon(
              Icons.star_rounded,
              color: AppColors.primary,
            ),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(
              Icons.settings_rounded,
              color: AppColors.primary,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
