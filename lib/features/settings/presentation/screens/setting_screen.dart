import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../converter/presentation/bottom_sheets/currency_picker_sheet.dart';
import '../../domain/entities/settings_entity.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// Screen allowing users to manage user profile identity, app configurations, cache, theme mode, and info.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _confirmClearCache(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF450A0A)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.trash,
                color: Color(0xFFEF4444),
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Clear Offline Cache?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will remove all cached exchange rates and historical snapshots from local storage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await context.read<SettingsCubit>().clearRatesCache();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Offline cache cleared successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Clear Cache',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Icon Badge: Soft rose circular background with rose user icon
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4C0519)
                      : const Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.person_fill,
                  color: Color(0xFFE11D48),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit Profile Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This name appears in your personalized dashboard greeting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            // Input TextField
            TextField(
              controller: controller,
              autofocus: true,
              cursorColor: const Color(0xFFE11D48),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.darkInputBox
                    : const Color(0xFFF9FAFB),
                hintText: 'Enter your name (e.g. Zainab)',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE11D48),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final newName = controller.text.trim();
                      Navigator.pop(ctx);
                      context
                          .read<SettingsCubit>()
                          .updateUserDisplayName(newName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newName.isNotEmpty
                                ? 'Profile name updated to "$newName"'
                                : 'Profile name cleared',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickBaseCurrency(BuildContext context, String current) async {
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: current,
    );
    if (picked != null && picked != current && context.mounted) {
      context.read<SettingsCubit>().updateDefaultBaseCurrency(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default base currency set to $picked'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _pickTargetCurrency(BuildContext context, String current) async {
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: current,
    );
    if (picked != null && picked != current && context.mounted) {
      context.read<SettingsCubit>().updateDefaultTargetCurrency(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default target currency set to $picked'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = AppColors.neonPurple;
    final primaryLightColor = AppColors.neonPink;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final cardBorder = isDark ? AppColors.darkBorder : theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. Dynamic User Profile Card
              _buildSectionHeader(context, 'User Profile'),
              Container(
                decoration: isDark
                    ? AppColors.neonCardDecoration(
                        color: isDark ? AppColors.darkCardSurface : theme.cardColor,
                        borderColor: cardBorder,
                        glow: true,
                      )
                    : BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder, width: 1.2),
                      ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _showEditNameDialog(context, state.userDisplayName),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.neonPink,
                                  AppColors.neonPurple
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonPurple
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                state.userDisplayName.trim().isNotEmpty
                                    ? state.userDisplayName
                                        .trim()[0]
                                        .toUpperCase()
                                    : '👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.userDisplayName.trim().isNotEmpty
                                      ? state.userDisplayName.trim()
                                      : 'Guest User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Personalize greeting on Home Dashboard',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEditNameDialog(
                                context, state.userDisplayName),
                            icon: Icon(
                              CupertinoIcons.pencil,
                              color: primaryLightColor,
                              size: 22,
                            ),
                            tooltip: 'Edit name',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. General Preferences
              _buildSectionHeader(context, 'General'),
              _buildCard(
                context,
                children: [
                  InkWell(
                    onTap: () =>
                        _pickBaseCurrency(context, state.defaultBaseCurrency),
                    child: _buildListTile(
                      context: context,
                      icon: CupertinoIcons.globe,
                      iconColor: primaryLightColor,
                      title: 'Default Base Currency',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.defaultBaseCurrency,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: primaryLightColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 14,
                              color: primaryLightColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  InkWell(
                    onTap: () => _pickTargetCurrency(
                        context, state.defaultTargetCurrency),
                    child: _buildListTile(
                      context: context,
                      icon: CupertinoIcons.money_dollar_circle,
                      iconColor: primaryLightColor,
                      title: 'Default Target Currency',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.defaultTargetCurrency,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: primaryLightColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 14,
                              color: primaryLightColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Appearance & Theme
              _buildSectionHeader(context, 'Appearance & Theme'),
              _buildCard(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.paintbrush,
                              color: primaryLightColor,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Theme Mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _buildThemeOption(
                              context: context,
                              isSelected:
                                  state.themeMode == AppThemeMode.system,
                              label: 'System',
                              icon: CupertinoIcons.circle_lefthalf_fill,
                              onTap: () =>
                                  cubit.updateThemeMode(AppThemeMode.system),
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              isSelected: state.themeMode == AppThemeMode.light,
                              label: 'Light',
                              icon: CupertinoIcons.sun_max_fill,
                              onTap: () =>
                                  cubit.updateThemeMode(AppThemeMode.light),
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              isSelected: state.themeMode == AppThemeMode.dark,
                              label: 'Dark',
                              icon: CupertinoIcons.moon_fill,
                              onTap: () =>
                                  cubit.updateThemeMode(AppThemeMode.dark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Storage & Cache
              _buildSectionHeader(context, 'Storage & Cache'),
              _buildCard(
                context,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CupertinoIcons.trash,
                          color: primaryLightColor,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        'Clear Offline Rates Cache',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Removes locally cached exchange rate snapshots',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      onTap: () => _confirmClearCache(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. About CurrencySnap
              _buildSectionHeader(context, 'About CurrencySnap'),
              _buildCard(
                context,
                children: [
                  _buildListTile(
                    context: context,
                    icon: CupertinoIcons.info_circle,
                    iconColor: primaryLightColor,
                    title: 'Application',
                    trailing: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  _buildListTile(
                    context: context,
                    icon: CupertinoIcons.number,
                    iconColor: primaryLightColor,
                    title: 'Version',
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  _buildListTile(
                    context: context,
                    icon: CupertinoIcons.cloud,
                    iconColor: primaryLightColor,
                    title: 'Rate Provider',
                    trailing: Text(
                      'Frankfurter API',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  _buildListTile(
                    context: context,
                    icon: CupertinoIcons.shield_lefthalf_fill,
                    iconColor: primaryLightColor,
                    title: 'License',
                    trailing: Text(
                      'MIT',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.neonPurple;
    final primaryLightColor = AppColors.neonPink;
    final surfaceAlt = theme.colorScheme.surfaceContainerHighest;
    final cardBorder = theme.dividerColor;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.15)
                : surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : cardBorder,
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDark ? primaryLightColor : primaryColor)
                    : textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : primaryColor)
                      : textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : theme.cardColor;
    final cardBorder = isDark ? AppColors.darkBorder : theme.dividerColor;

    return Container(
      decoration: isDark
          ? AppColors.neonCardDecoration(
              color: cardBg,
              borderColor: cardBorder,
              glow: false,
            )
          : BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Alias for SettingScreen
typedef SettingsScreen = SettingScreen;

