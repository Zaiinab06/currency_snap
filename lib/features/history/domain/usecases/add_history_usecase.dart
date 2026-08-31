import '../entities/conversion_history_entity.dart';
import '../repositories/history_repository.dart';

/// Use case to append a new record to conversion history.
class AddHistoryUseCase {
  final HistoryRepository repository;

  const AddHistoryUseCase(this.repository);

  Future<void> call(ConversionHistoryEntity item) {
    return repository.addHistory(item);
  }
}
