import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/error_banner.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../converter/presentation/cubit/convert_cubit.dart';
import '../../../historical_rates/presentation/screens/historical_rate_chart_screen.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/favorite_pair_tile.dart';

/// Screen displaying and managing the user's saved favorite currency pairs.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryLight = AppColors.neonPink;
    final surfaceColor =
        isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text(
          'Favorite Pairs',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.status == FavoritesStatus.loading &&
                state.favorites.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.status == FavoritesStatus.failure &&
                state.favorites.isEmpty) {
              return ErrorBanner(
                message:
                    state.errorMessage ?? 'Failed to load favorite pairs.',
                onRetry: () => context.read<FavoritesCubit>().loadFavorites(),
              );
            }

            if (state.favorites.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<FavoritesCubit>().loadFavorites(),
              color: primaryLight,
              backgroundColor: surfaceColor,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: state.favorites.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pair = state.favorites[index];
                  return FavoritePairTile(
                    key: ValueKey(pair.id),
                    pair: pair,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final convertCubit = context.read<ConvertCubit>();
                      convertCubit.changeSourceCurrency(pair.fromCurrency);
                      convertCubit.changeTargetCurrency(pair.toCurrency);
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => HistoricalRateChartScreen(
                            fromCurrency: pair.fromCurrency,
                            toCurrency: pair.toCurrency,
                            currentRate: pair.rate,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<FavoritesCubit>().removeFavorite(pair);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${pair.fromCurrency}/${pair.toCurrency} removed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final surfaceColor =
        isDark ? AppColors.darkCardSurface : theme.cardColor;
    final borderColor = isDark ? AppColors.darkBorder : theme.dividerColor;
    final primaryLight = AppColors.neonPink;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.neonPurple.withValues(alpha: 0.25),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                CupertinoIcons.star,
                color: primaryLight,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Favorite Pairs Saved',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your most converted currency pairs from the Home screen for instant tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
