import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final primaryLight = theme.colorScheme.secondary;
    final borderColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scaffoldBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
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
            if (_currentIndex != index) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: scaffoldBg,
          indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.25),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(CupertinoIcons.arrow_right_arrow_left, color: AppColors.textSecondary, size: 21),
              selectedIcon: Icon(
                CupertinoIcons.arrow_right_arrow_left,
                color: primaryLight,
                size: 22,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(CupertinoIcons.chart_bar_square, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                CupertinoIcons.chart_bar_square_fill,
                color: primaryLight,
                size: 23,
              ),
              label: 'Rates',
            ),
            NavigationDestination(
              icon: const Icon(CupertinoIcons.star, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                CupertinoIcons.star_fill,
                color: primaryLight,
                size: 23,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: const Icon(CupertinoIcons.clock, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                CupertinoIcons.clock_fill,
                color: primaryLight,
                size: 23,
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: const Icon(CupertinoIcons.gear, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(
                CupertinoIcons.gear_alt_fill,
                color: primaryLight,
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
