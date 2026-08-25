import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:currency_snap/core/utils/date_time_formatter.dart';

void main() {
  group('DateTimeFormatter', () {
    final referenceNow = DateTime(2026, 8, 25, 14, 30, 0);

    test('formats time difference < 1 min as "Updated just now"', () {
      final updated30sAgo = referenceNow.subtract(const Duration(seconds: 30));
      expect(
        DateTimeFormatter.formatRelativeTime(updated30sAgo, currentTime: referenceNow),
        'Updated just now',
      );
      expect(
        DateTimeFormatter.formatRelativeTime(
          updated30sAgo,
          currentTime: referenceNow,
          isFromCache: false,
        ),
        'Updated just now · Live',
      );
      expect(
        DateTimeFormatter.formatRelativeTime(
          updated30sAgo,
          currentTime: referenceNow,
          isFromCache: true,
        ),
        'Updated just now · Offline',
      );
    });

    test('formats time difference < 60 mins as "Updated Xm ago"', () {
      final updated15mAgo = referenceNow.subtract(const Duration(minutes: 15));
      expect(
        DateTimeFormatter.formatRelativeTime(updated15mAgo, currentTime: referenceNow),
        'Updated 15m ago',
      );
      expect(
        DateTimeFormatter.formatRelativeTime(
          updated15mAgo,
          currentTime: referenceNow,
          isFromCache: false,
        ),
        'Updated 15m ago · Live',
      );

      final updated1mAgo = referenceNow.subtract(const Duration(minutes: 1));
      expect(
        DateTimeFormatter.formatRelativeTime(updated1mAgo, currentTime: referenceNow),
        'Updated 1m ago',
      );

      final updated59mAgo = referenceNow.subtract(const Duration(minutes: 59));
      expect(
        DateTimeFormatter.formatRelativeTime(updated59mAgo, currentTime: referenceNow),
        'Updated 59m ago',
      );
    });

    test('formats time difference >= 60 mins & same day as "Updated Today at [hh:mm a]"', () {
      final updated2hAgo = referenceNow.subtract(const Duration(hours: 2));
      final expectedTimeStr = DateFormat('hh:mm a').format(updated2hAgo);
      expect(
        DateTimeFormatter.formatRelativeTime(updated2hAgo, currentTime: referenceNow),
        'Updated Today at $expectedTimeStr',
      );
      expect(
        DateTimeFormatter.formatRelativeTime(
          updated2hAgo,
          currentTime: referenceNow,
          isFromCache: false,
        ),
        'Updated Today at $expectedTimeStr · Live',
      );
    });

    test('formats older dates as "Updated on [dd MMM, hh:mm a]"', () {
      final updatedYesterday = referenceNow.subtract(const Duration(days: 1, hours: 2));
      final expectedDateStr = DateFormat('dd MMM, hh:mm a').format(updatedYesterday);
      expect(
        DateTimeFormatter.formatRelativeTime(updatedYesterday, currentTime: referenceNow),
        'Updated on $expectedDateStr',
      );
      expect(
        DateTimeFormatter.formatRelativeTime(
          updatedYesterday,
          currentTime: referenceNow,
          isFromCache: true,
        ),
        'Updated on $expectedDateStr · Offline',
      );
    });

    test('formatSyncTime formats same day as "Synced Today at [hh:mm a] · Live"', () {
      final syncTime = referenceNow.subtract(const Duration(minutes: 5));
      final expectedTimeStr = DateFormat('hh:mm a').format(syncTime);
      expect(
        DateTimeFormatter.formatSyncTime(
          syncTime,
          currentTime: referenceNow,
          isFromCache: false,
        ),
        'Synced Today at $expectedTimeStr · Live',
      );
      expect(
        DateTimeFormatter.formatSyncTime(
          syncTime,
          currentTime: referenceNow,
          isFromCache: true,
        ),
        'Synced Today at $expectedTimeStr · Offline',
      );
    });

    test('formatSyncTime formats past days as "Synced on [dd MMM, hh:mm a]"', () {
      final syncPast = referenceNow.subtract(const Duration(days: 2, hours: 3));
      final expectedDateStr = DateFormat('dd MMM, hh:mm a').format(syncPast);
      expect(
        DateTimeFormatter.formatSyncTime(
          syncPast,
          currentTime: referenceNow,
          isFromCache: false,
        ),
        'Synced on $expectedDateStr · Live',
      );
    });
  });
}
