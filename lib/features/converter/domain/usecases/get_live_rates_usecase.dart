import '../../../../core/constants/app_constants.dart';
import '../entities/currency_rate_entity.dart';
import '../repositories/converter_repository.dart';

/// Use case to fetch live or cached exchange rates.
class GetLiveRatesUseCase {
  final ConverterRepository repository;

  const GetLiveRatesUseCase(this.repository);

  Future<RateResultEntity> call({
    String baseCurrency = AppConstants.defaultBaseCurrency,
    bool forceRefresh = false,
  }) {
    return repository.getRates(baseCurrency, forceRefresh: forceRefresh);
  }
}
