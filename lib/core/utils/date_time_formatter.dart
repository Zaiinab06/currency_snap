import 'package:intl/intl.dart';

/// Utility for formatting timestamps into user-friendly relative and absolute time strings.
class DateTimeFormatter {
  DateTimeFormatter._();

  /// Formats a [lastUpdated] timestamp according to the exact relative rules:
  /// - Difference < 1 min: "Updated just now"
  /// - Difference < 60 mins: "Updated ${diff.inMinutes}m ago"
  /// - Difference >= 60 mins & same day: "Updated Today at ${DateFormat('hh:mm a').format(lastUpdated)}"
  /// - Older: "Updated on ${DateFormat('dd MMM, hh:mm a').format(lastUpdated)}"
  ///
  /// Optionally appends a status suffix (e.g. " · Live" or " · Offline") when [isFromCache] is provided.
  static String formatRelativeTime(
    DateTime lastUpdated, {
    DateTime? currentTime,
    bool? isFromCache,
  }) {
    final now = currentTime ?? DateTime.now();
    final diff = now.difference(lastUpdated);

    final String baseString;
    if (diff.inMinutes < 1 && diff.inSeconds >= -5) {
      baseString = 'Updated just now';
    } else if (diff.inMinutes < 60 && diff.inMinutes >= 1) {
      baseString = 'Updated ${diff.inMinutes}m ago';
    } else {
      final isSameDay = now.year == lastUpdated.year &&
          now.month == lastUpdated.month &&
          now.day == lastUpdated.day;
      if (isSameDay) {
        final timeStr = DateFormat('hh:mm a').format(lastUpdated);
        baseString = 'Updated Today at $timeStr';
      } else {
        final dateStr = DateFormat('dd MMM, hh:mm a').format(lastUpdated);
        baseString = 'Updated on $dateStr';
      }
    }

    if (isFromCache != null) {
      final suffix = isFromCache ? ' · Offline' : ' · Live';
      return '$baseString$suffix';
    }
    return baseString;
  }

  /// Formats [lastSyncTime] as a sync status string:
  /// - Same day: "Synced Today at ${DateFormat('hh:mm a').format(lastSyncTime)}"
  /// - Older: "Synced on ${DateFormat('dd MMM, hh:mm a').format(lastSyncTime)}"
  /// - Optionally appends " · Live" or " · Offline".
  static String formatSyncTime(
    DateTime lastSyncTime, {
    DateTime? currentTime,
    bool? isFromCache,
  }) {
    final now = currentTime ?? DateTime.now();
    final isSameDay = now.year == lastSyncTime.year &&
        now.month == lastSyncTime.month &&
        now.day == lastSyncTime.day;

    final String baseString;
    if (isSameDay) {
      final timeStr = DateFormat('hh:mm a').format(lastSyncTime);
      baseString = 'Synced Today at $timeStr';
    } else {
      final dateStr = DateFormat('dd MMM, hh:mm a').format(lastSyncTime);
      baseString = 'Synced on $dateStr';
    }

    if (isFromCache != null) {
      final suffix = isFromCache ? ' · Offline' : ' · Live';
      return '$baseString$suffix';
    }
    return baseString;
  }
}

/// Standalone top-level helper for formatting relative time.
String formatRelativeTime(
  DateTime lastUpdated, {
  DateTime? currentTime,
  bool? isFromCache,
}) =>
    DateTimeFormatter.formatRelativeTime(
      lastUpdated,
      currentTime: currentTime,
      isFromCache: isFromCache,
    );

/// Standalone top-level helper for formatting sync time.
String formatSyncTime(
  DateTime lastSyncTime, {
  DateTime? currentTime,
  bool? isFromCache,
}) =>
    DateTimeFormatter.formatSyncTime(
      lastSyncTime,
      currentTime: currentTime,
      isFromCache: isFromCache,
    );

