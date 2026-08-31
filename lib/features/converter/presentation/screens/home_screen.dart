import 'dart:async';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/common/error_banner.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../historical_rates/presentation/screens/historical_rate_chart_screen.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../bottom_sheets/currency_picker_sheet.dart';
import '../cubit/convert_cubit.dart';
import '../cubit/convert_state.dart';
import '../widgets/currency_input_card.dart';
import '../widgets/swap_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<double> _presetAmounts = [100, 500, 1000, 5000];
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  StreamSubscription<bool>? _autoFocusSub;
  bool _pendingAutoFocus = false;

  static const List<(String, String)> _popularPairs = [
    ('USD', 'EUR'),
    ('GBP', 'USD'),
    ('USD', 'PKR'),
    ('EUR', 'GBP'),
    ('USD', 'JPY'),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
    _amountFocusNode = FocusNode();
    context.read<ConvertCubit>().loadRates();
    context.read<FavoritesCubit>().loadFavorites();
    _initAutoFocus();
  }

  void _initAutoFocus() {
    _autoFocusSub = WidgetService.autoFocusStream.listen((shouldFocus) {
      if (shouldFocus && mounted) {
        _triggerAmountAutoFocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldFocus = await WidgetService.checkAutoFocusIntent();
      if (shouldFocus && mounted) {
        _triggerAmountAutoFocus();
      }
    });
  }

  void _triggerAmountAutoFocus() {
    _pendingAutoFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<ConvertCubit>().state;
      if (state is ConvertLoaded) {
        _pendingAutoFocus = false;
        if (!_amountFocusNode.hasFocus) {
          _amountFocusNode.requestFocus();
        }
        if (_amountController.text.isNotEmpty) {
          _amountController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _amountController.text.length,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoFocusSub?.cancel();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _pickCurrency({required bool isSource}) async {
    FocusScope.of(context).unfocus();
    _pendingAutoFocus = false;
    final cubit = context.read<ConvertCubit>();
    final state = cubit.state;
    if (state is! ConvertLoaded) return;

    final currentCode = isSource ? state.fromCurrency : state.toCurrency;
    final picked = await showCurrencyPickerSheet(
      context: context,
      selectedCode: currentCode,
      availableCodes: state.rates.rates.keys,
    );
    if (picked == null || picked == currentCode) return;

    if (isSource) {
      cubit.changeSourceCurrency(picked);
    } else {
      cubit.changeTargetCurrency(picked);
    }
    cubit.recordCurrentConversion();
  }

  Widget _buildFlagBadge(String currencyCode, bool isDark) {
    final flagCode = FlagCode.fromCurrencyCode(currencyCode);
    final countryCode = kCurrencyData[currencyCode]?.countryCode ??
        currencyCode.substring(
          0,
          currencyCode.length > 2 ? 2 : currencyCode.length,
        );
    final borderColor =
        isDark ? const Color(0xFF0F0A1A) : const Color(0xFFFFFFFF);

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 22,
          height: 22,
          child: flagCode != null
              ? CountryFlag.fromCurrencyCode(
                  currencyCode,
                  shape: const Circle(),
                )
              : CountryFlag.fromCountryCode(
                  countryCode,
                  shape: const Circle(),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Top Atmospheric Gradient Glow (Screen Canvas)
            if (isDark)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 240,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF3B1D63).withValues(alpha: 0.35),
                        const Color(0xFF07060A).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: BlocConsumer<ConvertCubit, ConvertState>(
                    listener: (context, state) {
                      if (state is ConvertLoaded) {
                        if (_pendingAutoFocus) {
                          _triggerAmountAutoFocus();
                        }
                        final parsed = CurrencyFormatter.parseAmount(
                          _amountController.text,
                        );
                        if ((parsed - state.amount).abs() > 0.001) {
                          final formattedAmount =
                              CurrencyFormatter.formatInputAmount(
                            state.amount,
                          );
                          _amountController.text = formattedAmount;
                          _amountController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: _amountController.text.length),
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is ConvertLoading || state is ConvertInitial) {
                        return const LoadingIndicator();
                      }
                      if (state is ConvertError) {
                        return ErrorBanner(
                          message: state.message,
                          onRetry: () => context.read<ConvertCubit>().loadRates(),
                        );
                      }
                      final loaded = state as ConvertLoaded;
                      return _buildLoadedContent(context, loaded);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ConvertLoaded state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF1E152A) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final sectionHeaderColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final unitRateColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final actionColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final actionAccentColor =
        isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48);
    final cubit = context.read<ConvertCubit>();

    final unitRate = state.rates.convertBetween(
          fromCurrency: state.fromCurrency,
          toCurrency: state.toCurrency,
          amount: 1.0,
        ) ??
        0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top: kIsWeb ? 20 : 8,
        left: 18,
        right: 18,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Vertical Header Stack (Top Bar + Full-width Greeting + Concise Live Status)
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) =>
                prev.userDisplayName != curr.userDisplayName,
            builder: (context, settingsState) {
              final name = settingsState.userDisplayName.trim();
              final avatarInitial =
                  name.isNotEmpty ? name[0].toUpperCase() : 'Z';
              final capitalizedName = name.isNotEmpty
                  ? name[0].toUpperCase() + name.substring(1)
                  : 'User';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1 (Top Bar): Avatar (left) + Action Buttons (right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar circle (size: 38x38, initial in bold white)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF43F5E),
                              Color(0xFF8B5CF6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            avatarInitial,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Notification Bell + Refresh Action Buttons (size: 36x36)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => cubit.refreshRates(forceRefresh: true),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF160F23)
                                      : AppColors.lightInputBox,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF382352) : border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: state.isRefreshing
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFF43F5E),
                                          ),
                                        )
                                      : Icon(
                                          CupertinoIcons.arrow_2_circlepath,
                                          color: textSecondary,
                                          size: 16,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Live rate notifications are active.',
                                    ),
                                    duration: Duration(milliseconds: 1200),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF160F23)
                                      : AppColors.lightInputBox,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF382352) : border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.bell,
                                      color: textSecondary,
                                      size: 16,
                                    ),
                                    Positioned(
                                      top: 9,
                                      right: 9,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF43F5E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2 (Greeting Text): Full width auto-capitalized
                  Text(
                    'Welcome, $capitalizedName',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Row 3: Single Concise Live Status Row (Green dot + Live · Synced today at...)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: state.isFromCache
                              ? AppColors.warning
                              : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (state.isFromCache
                                      ? AppColors.warning
                                      : const Color(0xFF10B981))
                                  .withValues(alpha: 0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.isFromCache
                            ? 'Cached · ${DateTimeFormatter.formatSyncTime(state.lastSyncTime)}'
                            : 'Live · ${DateTimeFormatter.formatSyncTime(state.lastSyncTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // "QUICK AMOUNT" Section Header Label
          Text(
            'QUICK AMOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sectionHeaderColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // 2. Quick Amount Pills (Height 32pt, BorderRadius 50 Stadium)
          Row(
            children: _presetAmounts.map((preset) {
              final isSelected = (state.amount - preset).abs() < 0.001;
              final presetDisplay = CurrencyFormatter.formatInputAmount(
                preset,
              );
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        FocusScope.of(context).unfocus();
                        _amountController.text = presetDisplay;
                        _amountController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                        cubit.updateAmount(preset);
                        cubit.recordCurrentConversion();
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        height: 32,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF43F5E),
                                    Color(0xFF8B5CF6),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (isDark
                                  ? const Color(0xFF140F22)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFB7185)
                                : (isDark
                                    ? const Color(0xFF281C3D)
                                    : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.2 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF43F5E)
                                        .withValues(alpha: 0.45),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          presetDisplay,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569)),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 3. Single Main Converter Card with Micro Unit Rate & Exact Center Swap Button
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF160F23) : theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF382352) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upper Section ('FROM')
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        bottom: 16,
                        left: 18,
                        right: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: sectionHeaderColor,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              CurrencyPill(
                                code: state.fromCurrency,
                                onTap: () => _pickCurrency(isSource: true),
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.7,
                              color: textPrimary,
                              height: 1.2,
                            ),
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(),
                            ],
                            cursorColor: theme.colorScheme.secondary,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: textSecondary.withValues(alpha: 0.5),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = CurrencyFormatter.parseAmount(value);
                              cubit.updateAmount(parsed);
                            },
                          ),
                          const SizedBox(height: 6),
                          // Micro Unit Rate Text: 11pt icon, 10.5sp font
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.info_circle,
                                size: 11,
                                color: unitRateColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '1 ${state.fromCurrency} = ${unitRate > 100 ? unitRate.toStringAsFixed(2) : unitRate.toStringAsFixed(4)} ${state.toCurrency}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: unitRateColor,
                                  fontSize: 10.5,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Hairline Center Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: border,
                    ),

                    // Lower Section ('TO')
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        bottom: 16,
                        left: 18,
                        right: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TO',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: sectionHeaderColor,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              CurrencyPill(
                                code: state.toCurrency,
                                onTap: () => _pickCurrency(isSource: false),
                                isDark: isDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.formatAmount(
                              state.convertedAmount ?? 0,
                              decimalDigits: 2,
                            ),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.7,
                              color: textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Hairline Footer Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: border,
                    ),

                    // Clean Inline Actions directly inside Main Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: View Historical Trend
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                FocusScope.of(context).unfocus();
                                _pendingAutoFocus = false;
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => HistoricalRateChartScreen(
                                      fromCurrency: state.fromCurrency,
                                      toCurrency: state.toCurrency,
                                      currentRate: unitRate,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.show_chart_rounded,
                                      size: 16,
                                      color: actionColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'View Historical Trend',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: actionColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Right: Save Pair wrapped in BlocBuilder<FavoritesCubit, FavoritesState>
                          BlocBuilder<FavoritesCubit, FavoritesState>(
                            builder: (context, favState) {
                              final favCubit = context.read<FavoritesCubit>();
                              final isFavorite = favCubit.isFavorite(
                                state.fromCurrency,
                                state.toCurrency,
                              );

                              return InkWell(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  FocusScope.of(context).unfocus();
                                  final wasAdded = await favCubit.toggleFavorite(
                                    state.fromCurrency,
                                    state.toCurrency,
                                    rate: unitRate,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          wasAdded
                                              ? '${state.fromCurrency}/${state.toCurrency} saved to favorites'
                                              : '${state.fromCurrency}/${state.toCurrency} removed from favorites',
                                        ),
                                        duration:
                                            const Duration(milliseconds: 1400),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isFavorite
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 18,
                                        color: isFavorite
                                            ? actionAccentColor
                                            : actionColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isFavorite ? 'Saved' : 'Save Pair',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isFavorite
                                              ? actionAccentColor
                                              : actionColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Floating Swap Button (38x38pt) centered over divider between FROM and TO
                Positioned(
                  top: 107,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SwapButton(
                      size: 38,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        cubit.swapCurrencies();
                        cubit.recordCurrentConversion();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 5. Popular Pairs Section
          Text(
            'POPULAR PAIRS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sectionHeaderColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),

          // Flat Modern List Structure (Direct list sharing identical rhythm and divider styling)
          Builder(
            builder: (context) {
              final popularPairs = state.rates.getPopularPairs(
                _popularPairs,
                previousRates: state.previousRates,
              );

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: popularPairs.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: border,
                ),
                itemBuilder: (context, index) {
                  final pair = popularPairs[index];
                  final isPositive = pair.isPositive;
                  final rateStr = pair.rate > 100
                      ? pair.rate.toStringAsFixed(2)
                      : pair.rate.toStringAsFixed(4);
                  final deltaStr =
                      '${isPositive ? '+' : ''}${pair.percentChange.toStringAsFixed(1)}% ${isPositive ? '↑' : '↓'}';

                  final badgeBg = isPositive
                      ? (isDark
                          ? const Color(0xFF064E3B)
                          : const Color(0xFFD1FAE5))
                      : (isDark
                          ? const Color(0xFF4C0519)
                          : const Color(0xFFFFE4E6));
                  final badgeTextColor = isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF43F5E);
                  final rateColor = isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        FocusScope.of(context).unfocus();
                        cubit.changeSourceCurrency(pair.baseCurrency);
                        cubit.changeTargetCurrency(pair.quoteCurrency);
                        cubit.recordCurrentConversion();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            // Dual Overlapping Flag Stack (36x22pt with 22x22 flags)
                            SizedBox(
                              width: 36,
                              height: 22,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: _buildFlagBadge(
                                      pair.baseCurrency,
                                      isDark,
                                    ),
                                  ),
                                  Positioned(
                                    left: 14,
                                    child: _buildFlagBadge(
                                      pair.quoteCurrency,
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Clean Pair Title (14sp, w600)
                            Text(
                              '${pair.baseCurrency} / ${pair.quoteCurrency}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),

                            const Spacer(),

                            // Subtle, Non-Bold Micro Rate Typography (12.5sp, w400)
                            Text(
                              rateStr,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: rateColor,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Percentage Delta Pill (padding: 6x3)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                deltaStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Trailing Chevron (size: 16)
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
