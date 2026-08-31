import 'package:currency_snap/features/converter/presentation/screens/home_screen.dart';
import 'package:currency_snap/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:currency_snap/features/historical_rates/presentation/screens/rates_screen.dart';
import 'package:currency_snap/features/history/presentation/screens/history_screen.dart';
import 'package:currency_snap/features/settings/presentation/screens/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final navBg = isDark
        ? AppColors.darkNavBackground
        : AppColors.lightNavBackground;
    const primaryAccent = AppColors.primary;
    final unselectedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
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
              FocusScope.of(context).unfocus();
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: navBg,
          indicatorColor: primaryAccent.withValues(alpha: isDark ? 0.25 : 0.15),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.arrow_right_arrow_left,
                color: unselectedColor,
                size: 21,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.arrow_right_arrow_left,
                color: primaryAccent,
                size: 22,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.chart_bar_square,
                color: unselectedColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.chart_bar_square_fill,
                color: primaryAccent,
                size: 23,
              ),
              label: 'Rates',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.star, color: unselectedColor, size: 22),
              selectedIcon: const Icon(
                CupertinoIcons.star_fill,
                color: primaryAccent,
                size: 23,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.clock,
                color: unselectedColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.clock_fill,
                color: primaryAccent,
                size: 23,
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.gear, color: unselectedColor, size: 22),
              selectedIcon: const Icon(
                CupertinoIcons.gear_alt_fill,
                color: primaryAccent,
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
