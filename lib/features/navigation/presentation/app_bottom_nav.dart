import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../converter/presentation/screens/home_screen.dart';
import '../../favorites/presentation/screens/favorites_screen.dart';
import '../../historical_rates/presentation/screens/rates_screen.dart';
import '../../history/presentation/screens/history_screen.dart';
import '../../settings/presentation/screens/setting_screen.dart';

/// Main navigation container preserving tab states across 5 primary fintech modules via an IndexedStack.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    RatesScreen(),
    FavoritesScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final navBg =
        isDark ? AppColors.darkNavBackground : AppColors.lightNavBackground;
    const activeColor = Color(0xFFFF3366);
    final inactiveColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final indicatorColor =
        isDark ? const Color(0xFF4B1528) : const Color(0xFFFCE7F3);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
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
          indicatorColor: indicatorColor,
          indicatorShape: const StadiumBorder(),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.house,
                color: inactiveColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.house_fill,
                color: activeColor,
                size: 22,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.chart_bar_square,
                color: inactiveColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.chart_bar_square_fill,
                color: activeColor,
                size: 23,
              ),
              label: 'Rates',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.star,
                color: inactiveColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.star_fill,
                color: activeColor,
                size: 23,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.clock,
                color: inactiveColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.clock_fill,
                color: activeColor,
                size: 23,
              ),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(
                CupertinoIcons.gear,
                color: inactiveColor,
                size: 22,
              ),
              selectedIcon: const Icon(
                CupertinoIcons.gear_alt_fill,
                color: activeColor,
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
