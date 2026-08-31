import '../repositories/history_repository.dart';

/// Use case to clear all conversion history records.
class ClearHistoryUseCase {
  final HistoryRepository repository;

  const ClearHistoryUseCase(this.repository);

  Future<void> call() {
    return repository.clearHistory();
  }

  Future<void> deleteItem(String id) {
    return repository.deleteHistoryItem(id);
  }
}
