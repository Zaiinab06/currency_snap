import '../../domain/entities/conversion_history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/conversion_history_model.dart';

/// Implementation of [HistoryRepository] mapping between domain entities and data models.
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _localDataSource;

  HistoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<ConversionHistoryEntity>> getHistory() async {
    return _localDataSource.getHistory();
  }

  @override
  Future<void> addHistory(ConversionHistoryEntity item) async {
    final model = item is ConversionHistoryModel
        ? item
        : ConversionHistoryModel.fromEntity(item);
    await _localDataSource.addHistory(model);
  }

  @override
  Future<void> deleteHistoryItem(String id) {
    return _localDataSource.deleteHistoryItem(id);
  }

  @override
  Future<void> clearHistory() {
    return _localDataSource.clearHistory();
  }
}
