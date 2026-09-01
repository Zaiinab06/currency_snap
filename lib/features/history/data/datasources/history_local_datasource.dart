import 'dart:async';
import 'dart:convert';
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

/// Local data source responsible for persisting and managing conversion history logs.
class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final SharedPreferences _prefs;
  final _historyStreamController =
      StreamController<List<ConversionHistoryModel>>.broadcast();

  HistoryLocalDataSourceImpl(this._prefs);

  static const int _maxHistoryCount = 50;

  @override
  Stream<List<ConversionHistoryModel>> get historyStream =>
      _historyStreamController.stream;

  @override
  Future<List<ConversionHistoryModel>> getHistory() async {
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

    final updated = [item, ...current];
    if (updated.length > _maxHistoryCount) {
      updated.removeRange(_maxHistoryCount, updated.length);
    }
    await _saveAll(updated);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final current = await getHistory();
    final updated = current.where((item) => item.id != id).toList();
    await _saveAll(updated);
  }

  @override
  Future<void> clearHistory() async {
    await _prefs.remove(AppConstants.prefKeyHistory);
    _historyStreamController.add(const []);
  }

  Future<void> _saveAll(List<ConversionHistoryModel> items) async {
    final jsonString =
        jsonEncode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(AppConstants.prefKeyHistory, jsonString);
    _historyStreamController.add(List.unmodifiable(items));
  }
}
