import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/widget_service.dart';
import '../../../favorites/domain/entities/favorite_pair_entity.dart';
import '../../../favorites/domain/repositories/favorites_repository.dart';
import '../../../history/domain/entities/conversion_history_entity.dart';
import '../../../history/domain/repositories/history_repository.dart';
import '../../domain/repositories/converter_repository.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/get_live_rates_usecase.dart';
import 'convert_state.dart';

/// Drives the Home/Converter screen.
class ConvertCubit extends Cubit<ConvertState> {
  final GetLiveRatesUseCase _getLiveRatesUseCase;
  final ConvertCurrencyUseCase _convertCurrencyUseCase;
  final FavoritesRepository _favoritesRepository;
  final HistoryRepository _historyRepository;

  ConvertCubit(
    this._getLiveRatesUseCase,
    this._convertCurrencyUseCase,
    this._favoritesRepository,
    this._historyRepository,
  ) : super(const ConvertInitial());

  /// Convenience constructor taking repository contracts directly.
  factory ConvertCubit.fromRepositories({
    required ConverterRepository converterRepository,
    required FavoritesRepository favoritesRepository,
    required HistoryRepository historyRepository,
  }) {
    return ConvertCubit(
      GetLiveRatesUseCase(converterRepository),
      const ConvertCurrencyUseCase(),
      favoritesRepository,
      historyRepository,
    );
  }

  /// Refreshes exchange rates by triggering a fresh network call.
  Future<void> refreshRates({bool forceRefresh = true}) async {
    final current = state;
    if (current is ConvertLoaded) {
      await loadRates(
        fromCurrency: current.fromCurrency,
        toCurrency: current.toCurrency,
        amount: current.amount,
        forceRefresh: forceRefresh,
      );
    } else {
      await loadRates(forceRefresh: forceRefresh);
    }
  }

  /// Fetches the anchor rate table once and sets up the initial from/to pair.
  Future<void> loadRates({
    String fromCurrency = AppConstants.defaultBaseCurrency,
    String toCurrency = AppConstants.defaultTargetCurrency,
    double amount = 100,
    bool forceRefresh = false,
  }) async {
    final current = state;
    if (current is ConvertLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const ConvertLoading());
    }

    try {
      final result = await _getLiveRatesUseCase(
        baseCurrency: AppConstants.defaultBaseCurrency,
        forceRefresh: forceRefresh,
      );
      final converted = _convertCurrencyUseCase(
        rates: result.rates,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
      );

      final newState = ConvertLoaded(
        rates: result.rates,
        previousRates: result.previousRates,
        isFromCache: result.isFromCache,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        convertedAmount: converted,
        isRefreshing: false,
        lastSyncTime: result.syncTime,
      );

      emit(newState);
      _syncWidget(newState);
    } on NoCachedDataException catch (e) {
      emit(ConvertError(e.message));
    } on ServerException catch (e) {
      emit(ConvertError(e.message));
    } on NetworkException catch (e) {
      emit(ConvertError(e.message));
    } catch (e) {
      emit(const ConvertError('Something went wrong. Please try again.'));
    }
  }

  /// Recalculates the converted amount for a new input amount.
  void updateAmount(double newAmount) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = _convertCurrencyUseCase(
      rates: current.rates,
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      amount: newAmount,
    );

    final newState = current.copyWith(
      amount: newAmount,
      convertedAmount: converted,
    );
    emit(newState);
    _syncWidget(newState);
  }

  /// Swaps "from" and "to" and recalculates.
  void swapCurrencies() {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = _convertCurrencyUseCase(
      rates: current.rates,
      fromCurrency: current.toCurrency,
      toCurrency: current.fromCurrency,
      amount: current.amount,
    );

    final newState = current.copyWith(
      fromCurrency: current.toCurrency,
      toCurrency: current.fromCurrency,
      convertedAmount: converted,
    );

    emit(newState);
    _syncWidget(newState);
  }

  /// Changes the source ("you send") currency and recalculates.
  void changeSourceCurrency(String newSourceCurrency) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = _convertCurrencyUseCase(
      rates: current.rates,
      fromCurrency: newSourceCurrency,
      toCurrency: current.toCurrency,
      amount: current.amount,
    );

    final newState = current.copyWith(
      fromCurrency: newSourceCurrency,
      convertedAmount: converted,
    );

    emit(newState);
    _syncWidget(newState);
  }

  /// Changes the target ("they receive") currency and recalculates.
  void changeTargetCurrency(String newTargetCurrency) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = _convertCurrencyUseCase(
      rates: current.rates,
      fromCurrency: current.fromCurrency,
      toCurrency: newTargetCurrency,
      amount: current.amount,
    );

    final newState = current.copyWith(
      toCurrency: newTargetCurrency,
      convertedAmount: converted,
    );

    emit(newState);
    _syncWidget(newState);
  }

  /// Saves the currently displayed pair to favorites.
  Future<void> saveCurrentPairToFavorites() async {
    final current = state;
    if (current is! ConvertLoaded) return;

    final rate = _convertCurrencyUseCase(
      rates: current.rates,
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      amount: 1,
    );
    if (rate == null) return;

    final pair = FavoritePairEntity.create(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      rate: rate,
    );
    await _favoritesRepository.addFavorite(pair);
  }

  /// Persists the currently calculated conversion to conversion history.
  Future<void> recordCurrentConversion() async {
    final current = state;
    if (current is! ConvertLoaded || current.convertedAmount == null) return;
    if (current.amount <= 0) return;

    final unitRate = _convertCurrencyUseCase(
          rates: current.rates,
          fromCurrency: current.fromCurrency,
          toCurrency: current.toCurrency,
          amount: 1,
        ) ??
        (current.convertedAmount! / current.amount);

    final historyItem = ConversionHistoryEntity.create(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      fromAmount: current.amount,
      toAmount: current.convertedAmount!,
      rate: unitRate,
    );
    await _historyRepository.addHistory(historyItem);
  }

  /// Helper to push updated currency rate data to the Native Home Screen Widget.
  void _syncWidget(ConvertLoaded loadedState) {
    final unitRate = _convertCurrencyUseCase(
      rates: loadedState.rates,
      fromCurrency: loadedState.fromCurrency,
      toCurrency: loadedState.toCurrency,
      amount: 1,
    );

    if (unitRate != null) {
      final timeStr =
          'Synced at ${loadedState.lastSyncTime.hour.toString().padLeft(2, '0')}:${loadedState.lastSyncTime.minute.toString().padLeft(2, '0')}';

      WidgetService.syncHomeWidget(
        baseCurrency: loadedState.fromCurrency,
        targetCurrency: loadedState.toCurrency,
        rate: unitRate,
        updatedTime: timeStr,
        amount: loadedState.amount,
      );
    }
  }
}
