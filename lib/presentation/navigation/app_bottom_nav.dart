import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/rates/rates_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/setting_screen.dart';

/// Main navigation container preserving tab states across 5 primary fintech modules via an IndexedStack.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RatesScreen(),
    FavoritesScreen(),
    HistoryScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.28),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.currency_exchange_outlined, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                Icons.currency_exchange_rounded,
                color: AppColors.primaryLight,
                size: 23,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                Icons.insights_rounded,
                color: AppColors.primaryLight,
                size: 23,
              ),
              label: 'Rates',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline_rounded, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                Icons.star_rounded,
                color: AppColors.primaryLight,
                size: 23,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_toggle_off_rounded, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                Icons.history_rounded,
                color: AppColors.primaryLight,
                size: 23,
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: AppColors.primaryLight,
                size: 23,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

