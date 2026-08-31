import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Standard loading state — centered spinner in the primary accent color.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
