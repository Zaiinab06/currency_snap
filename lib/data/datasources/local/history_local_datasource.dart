import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/conversion_history_model.dart';
import '../../../core/constants/app_constants.dart';

/// Local data source responsible for persisting and managing conversion history logs.
class HistoryLocalDataSource {
  final SharedPreferences _prefs;

  HistoryLocalDataSource(this._prefs);

  static const int _maxHistoryCount = 50;

  /// Retrieves all persisted conversion history logs.
  /// If no logs exist yet in storage, seeds initial realistic samples for immediate feedback.
  Future<List<ConversionHistoryModel>> getHistory() async {
    final jsonString = _prefs.getString(AppConstants.prefKeyHistory);
    if (jsonString == null) {
      final initialLogs = _buildInitialSeedLogs();
      await _saveAll(initialLogs);
      return initialLogs;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final logs = decoded
          .map((item) => ConversionHistoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort newest first
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    } catch (_) {
      return [];
    }
  }

  /// Adds a new conversion history record to the beginning of the list and persists it.
  Future<void> addHistory(ConversionHistoryModel item) async {
    final current = await getHistory();
    // Prepend new item and avoid direct identical duplicate within last 2 seconds
    if (current.isNotEmpty) {
      final first = current.first;
      final isSamePair = first.fromCurrency == item.fromCurrency &&
          first.toCurrency == item.toCurrency &&
          (first.fromAmount - item.fromAmount).abs() < 0.001;
      final isRecent = DateTime.now().difference(first.timestamp).inSeconds < 3;
      if (isSamePair && isRecent) {
        return;
      }
    }

    final updated = [item, ...current];
    if (updated.length > _maxHistoryCount) {
      updated.removeRange(_maxHistoryCount, updated.length);
    }
    await _saveAll(updated);
  }

  /// Deletes a specific conversion history record identified by [id].
  Future<void> deleteHistoryItem(String id) async {
    final current = await getHistory();
    final updated = current.where((item) => item.id != id).toList();
    await _saveAll(updated);
  }

  /// Clears all conversion history records from local storage.
  Future<void> clearHistory() async {
    await _prefs.remove(AppConstants.prefKeyHistory);
  }

  Future<void> _saveAll(List<ConversionHistoryModel> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(AppConstants.prefKeyHistory, jsonString);
  }

  List<ConversionHistoryModel> _buildInitialSeedLogs() {
    final now = DateTime.now();
    return [
      ConversionHistoryModel(
        id: 'USD_EUR_1',
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        fromAmount: 500,
        toAmount: 460.00,
        rate: 0.9200,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      ConversionHistoryModel(
        id: 'GBP_USD_2',
        fromCurrency: 'GBP',
        toCurrency: 'USD',
        fromAmount: 1000,
        toAmount: 1265.00,
        rate: 1.2650,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
      ConversionHistoryModel(
        id: 'USD_PKR_3',
        fromCurrency: 'USD',
        toCurrency: 'PKR',
        fromAmount: 100,
        toAmount: 27850.00,
        rate: 278.50,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ConversionHistoryModel(
        id: 'EUR_GBP_4',
        fromCurrency: 'EUR',
        toCurrency: 'GBP',
        fromAmount: 250,
        toAmount: 214.25,
        rate: 0.8570,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      ConversionHistoryModel(
        id: 'USD_JPY_5',
        fromCurrency: 'USD',
        toCurrency: 'JPY',
        fromAmount: 1000,
        toAmount: 154300.00,
        rate: 154.30,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
      ),
    ];
  }
}
