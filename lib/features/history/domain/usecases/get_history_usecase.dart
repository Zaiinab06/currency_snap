import '../entities/conversion_history_entity.dart';
import '../repositories/history_repository.dart';

/// Use case to retrieve conversion history logs.
class GetHistoryUseCase {
  final HistoryRepository repository;

  const GetHistoryUseCase(this.repository);

  Future<List<ConversionHistoryEntity>> call() {
    return repository.getHistory();
  }
}
