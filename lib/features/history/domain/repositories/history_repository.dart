import '../entities/conversion_history_entity.dart';

/// Abstract domain contract for conversion history log operations.
abstract class HistoryRepository {
  Stream<List<ConversionHistoryEntity>> get historyStream;
  Future<List<ConversionHistoryEntity>> getHistory();
  Future<void> addHistory(ConversionHistoryEntity item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}
