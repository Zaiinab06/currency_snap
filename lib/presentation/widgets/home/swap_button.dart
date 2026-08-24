import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The circular swap button positioned between the "You send" and
/// "They receive" cards. 44x44pt touch target per Apple HIG.
class SwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const SwapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.accent,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 3),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.swap_vert_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

