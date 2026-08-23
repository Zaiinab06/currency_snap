import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The circular swap button positioned between the "You send" and
/// "They receive" cards. 44x44pt touch target per Apple HIG.
class SwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const SwapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.swap_vert_rounded,
            color: AppColors.onPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
