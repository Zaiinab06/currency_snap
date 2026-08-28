import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../bloc/convert/convert_cubit.dart';
import '../../../bloc/favorites/favorites_cubit.dart';
import '../../../bloc/favorites/favorites_state.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/favorites/favorite_pair_tile.dart';
import '../historical_rates/historical_rate_chart_screen.dart';

/// Screen displaying and managing the user's saved favorite currency pairs with dynamic theming.
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
    final isLight = theme.brightness == Brightness.light;
    final scaffoldBg = isLight ? theme.scaffoldBackgroundColor : AppColors.scaffoldBackground;
    final primaryLight = AppColors.primaryLight;
    final surfaceColor = isLight ? Colors.white : AppColors.surface;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        title: const Text(
          'Favorite Pairs',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.status == FavoritesStatus.loading && state.favorites.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.status == FavoritesStatus.failure && state.favorites.isEmpty) {
              return ErrorBanner(
                message: state.errorMessage ?? 'Failed to load favorite pairs.',
                onRetry: () => context.read<FavoritesCubit>().loadFavorites(),
              );
            }

            if (state.favorites.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<FavoritesCubit>().loadFavorites(),
              color: primaryLight,
              backgroundColor: surfaceColor,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: state.favorites.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                          content: Text('${pair.fromCurrency}/${pair.toCurrency} removed'),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final primaryLight = theme.colorScheme.secondary;

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
              ),
              child: Icon(
                CupertinoIcons.star,
                color: primaryLight,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No favorite pairs saved',
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
