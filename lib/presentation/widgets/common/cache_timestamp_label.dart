import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Shows "Rates cached · last updated Xh ago" when the app is using
/// offline data, or "Live · updated just now" when data is fresh.
class CacheTimestampLabel extends StatelessWidget {
  final bool isFromCache;
  final DateTime lastUpdated;

  const CacheTimestampLabel({
    super.key,
    required this.isFromCache,
    required this.lastUpdated,
  });

  String get _relativeTime {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFromCache ? CupertinoIcons.cloud_bolt : CupertinoIcons.bolt_fill,
          size: 13,
          color: isFromCache ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          isFromCache
              ? 'Rates cached · updated $_relativeTime'
              : 'Live · updated $_relativeTime',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
