import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/settings/settings_cubit.dart';
import '../../../bloc/settings/settings_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/currency_repository.dart';
import '../../bottom_sheets/currency_picker_sheet.dart';

/// Screen allowing users to manage app configurations, cache, theme mode, and info.
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    final repository = context.read<CurrencyRepository>();
    await repository.clearCache();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline rate cache cleared successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
    final primaryColor = theme.colorScheme.primary;
    final primaryLightColor = theme.colorScheme.secondary;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
              _buildSectionHeader(context, 'General'),
              _buildCard(
                context,
                children: [
                  InkWell(
                    onTap: () => _pickBaseCurrency(context, state.defaultBaseCurrency),
                    child: _buildListTile(
                      context: context,
                      icon: CupertinoIcons.globe,
                      iconColor: primaryLightColor,
                      title: 'Default Base Currency',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            Icon(CupertinoIcons.chevron_down, size: 14, color: primaryLightColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  InkWell(
                    onTap: () => _pickTargetCurrency(context, state.defaultTargetCurrency),
                    child: _buildListTile(
                      context: context,
                      icon: CupertinoIcons.money_dollar_circle,
                      iconColor: primaryLightColor,
                      title: 'Default Target Currency',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            Icon(CupertinoIcons.chevron_down, size: 14, color: primaryLightColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              isSelected: state.themeMode == AppThemeMode.system,
                              label: 'System',
                              icon: CupertinoIcons.circle_lefthalf_fill,
                              onTap: () => cubit.updateThemeMode(AppThemeMode.system),
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              isSelected: state.themeMode == AppThemeMode.light,
                              label: 'Light',
                              icon: CupertinoIcons.sun_max_fill,
                              onTap: () => cubit.updateThemeMode(AppThemeMode.light),
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              isSelected: state.themeMode == AppThemeMode.dark,
                              label: 'Dark',
                              icon: CupertinoIcons.moon_fill,
                              onTap: () => cubit.updateThemeMode(AppThemeMode.dark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(context, 'Storage & Cache'),
              _buildCard(
                context,
                children: [
                  ListTile(
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
                    onTap: () => _clearCache(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                      'Open Exchange Rates',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryLightColor,
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
    final primaryColor = theme.colorScheme.primary;
    final primaryLightColor = theme.colorScheme.secondary;
    final surfaceAlt = theme.colorScheme.surfaceContainerHighest;
    final cardBorder = theme.dividerColor;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
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
                color: isSelected ? (isDark ? primaryLightColor : primaryColor) : textSecondary,
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
    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
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
