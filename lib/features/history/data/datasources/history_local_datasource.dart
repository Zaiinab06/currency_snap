import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/conversion_history_model.dart';

/// Contract for conversion history local data source.
abstract class HistoryLocalDataSource {
  Stream<List<ConversionHistoryModel>> get historyStream;
  Future<List<ConversionHistoryModel>> getHistory();
  Future<void> addHistory(ConversionHistoryModel item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}

/// Local data source responsible for persisting and managing conversion history logs using structured Hive database caching.
class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Box<Map>? _box;
  final SharedPreferences? _prefs;
  final _historyStreamController =
      StreamController<List<ConversionHistoryModel>>.broadcast();

  HistoryLocalDataSourceImpl([this._box, this._prefs]);

  static const int _maxHistoryCount = 50;

  @override
  Stream<List<ConversionHistoryModel>> get historyStream =>
      _historyStreamController.stream;

  @override
  Future<List<ConversionHistoryModel>> getHistory() async {
    if (_box != null && _box.isOpen) {
      if (_box.isNotEmpty) {
        final logs = _box.values
            .map((item) => ConversionHistoryModel.fromJson(
                Map<String, dynamic>.from(item)))
            .toList();
        logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return logs;
      }
      // Migrate from legacy SharedPreferences if present
      if (_prefs != null) {
        final jsonString = _prefs.getString(AppConstants.prefKeyHistory);
        if (jsonString != null && jsonString.isNotEmpty) {
          try {
            final List<dynamic> decoded =
                jsonDecode(jsonString) as List<dynamic>;
            final logs = decoded
                .map((item) => ConversionHistoryModel.fromJson(
                    item as Map<String, dynamic>))
                .toList();
            for (final item in logs) {
              await _box.put(item.id, item.toJson());
            }
            await _prefs.remove(AppConstants.prefKeyHistory);
            logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return logs;
          } catch (_) {}
        }
      }
      return [];
    }

    // Fallback if box is not passed
    if (_prefs != null) {
      final jsonString = _prefs.getString(AppConstants.prefKeyHistory);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      try {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        final logs = decoded
            .map((item) =>
                ConversionHistoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return logs;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> addHistory(ConversionHistoryModel item) async {
    final current = await getHistory();
    if (current.isNotEmpty) {
      final first = current.first;
      final isSamePair = first.fromCurrency == item.fromCurrency &&
          first.toCurrency == item.toCurrency &&
          (first.fromAmount - item.fromAmount).abs() < 0.001;
      final isRecent =
          DateTime.now().difference(first.timestamp).inSeconds < 3;
      if (isSamePair && isRecent) {
        return;
      }
    }

    if (_box != null && _box.isOpen) {
      await _box.put(item.id, item.toJson());
      final updated = await getHistory();
      if (updated.length > _maxHistoryCount) {
        final toRemove = updated.sublist(_maxHistoryCount);
        for (final rem in toRemove) {
          await _box.delete(rem.id);
        }
      }
      final finalList = await getHistory();
      _historyStreamController.add(List.unmodifiable(finalList));
      return;
    }

    final updated = [item, ...current];
    if (updated.length > _maxHistoryCount) {
      updated.removeRange(_maxHistoryCount, updated.length);
    }
    await _saveAllPrefs(updated);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    if (_box != null && _box.isOpen) {
      await _box.delete(id);
      final updated = await getHistory();
      _historyStreamController.add(List.unmodifiable(updated));
      return;
    }
    final current = await getHistory();
    final updated = current.where((item) => item.id != id).toList();
    await _saveAllPrefs(updated);
  }

  @override
  Future<void> clearHistory() async {
    if (_box != null && _box.isOpen) {
      await _box.clear();
      _historyStreamController.add(const []);
      return;
    }
    if (_prefs != null) {
      await _prefs.remove(AppConstants.prefKeyHistory);
    }
    _historyStreamController.add(const []);
  }

  Future<void> _saveAllPrefs(List<ConversionHistoryModel> items) async {
    if (_prefs != null) {
      final jsonString =
          jsonEncode(items.map((item) => item.toJson()).toList());
      await _prefs.setString(AppConstants.prefKeyHistory, jsonString);
    }
    _historyStreamController.add(List.unmodifiable(items));
  }
}
