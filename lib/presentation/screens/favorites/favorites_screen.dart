import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/favorites/favorites_cubit.dart';
import '../../../bloc/favorites/favorites_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/error_banner.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/favorites/favorite_pair_tile.dart';

/// Screen displaying and managing the user's saved favorite currency pairs in Midnight Neon theme.
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
              color: AppColors.primaryLight,
              backgroundColor: AppColors.surface,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: state.favorites.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pair = state.favorites[index];
                  return FavoritePairTile(
                    key: ValueKey(pair.id),
                    pair: pair,
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
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.star_border_rounded,
                color: AppColors.primaryLight,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No favorite pairs saved',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your most converted currency pairs from the Home screen for instant tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

