import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Friendly, styled error view with cloud-off icon and gradient retry button.
class RatesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RatesErrorWidget({
    super.key,
    this.message =
        'Unable to load historical rates.\nPlease check your connection and try again.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    const iconColor = Color(0xFF6B7280);
    final labelMutedColor =
        isLight ? const Color(0xFF6B7280) : AppColors.darkTextSecondary;
    final titleColor =
        isLight ? const Color(0xFF111827) : Colors.white;

    // Clean any concatenated exception class names and enforce clean typography
    final String displayMessage;
    if (message.contains('Unable to load') ||
        message.contains('NoCachedData') ||
        message.contains('SocketException') ||
        message.contains('NetworkException') ||
        message.contains('Connection') ||
        message.contains('Exception')) {
      displayMessage =
          'Unable to load historical rates.\nPlease check your connection and try again.';
    } else {
      final sanitized = message
          .replaceFirst(RegExp(r'^[A-Za-z0-9_]*Exception:\s*'), '')
          .replaceFirst(RegExp(r'^NoCachedData[A-Za-z]*:?\s*'), '')
          .trim();
      displayMessage =
          sanitized.isNotEmpty && !sanitized.startsWith('Instance of')
              ? sanitized
              : 'Unable to load historical rates.\nPlease check your connection and try again.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xFFF3F4F6)
                    : AppColors.darkInputBox,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Issue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: labelMutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onRetry();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF3366),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3366).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_clockwise,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
