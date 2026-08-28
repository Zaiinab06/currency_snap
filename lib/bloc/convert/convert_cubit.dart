import 'package:currency_snap/data/models/favorite_pair_model.dart';
import 'package:currency_snap/data/models/conversion_history_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/services/widget_service.dart';
import '../../data/repositories/currency_repository.dart';
import 'convert_state.dart';

/// Drives the Home/Converter screen.
class ConvertCubit extends Cubit<ConvertState> {
  final CurrencyRepository _repository;

  ConvertCubit(this._repository) : super(const ConvertInitial());

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
      final result = await _repository.getRates(
        AppConstants.defaultBaseCurrency,
        forceRefresh: forceRefresh,
      );
      final converted = result.rates.convertBetween(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
      );

      final newState = ConvertLoaded(
        rates: result.rates,
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
    } catch (e) {
      emit(const ConvertError('Something went wrong. Please try again.'));
    }
  }

  /// Recalculates the converted amount for a new input amount.
  void updateAmount(double newAmount) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convertBetween(
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

    final converted = current.rates.convertBetween(
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

    final converted = current.rates.convertBetween(
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

    final converted = current.rates.convertBetween(
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

    final rate = current.rates.convertBetween(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      amount: 1,
    );
    if (rate == null) return;

    final pair = FavoritePairModel.create(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      rate: rate,
    );
    await _repository.addFavorite(pair);
  }

  /// Persists the currently calculated conversion to conversion history.
  Future<void> recordCurrentConversion() async {
    final current = state;
    if (current is! ConvertLoaded || current.convertedAmount == null) return;
    if (current.amount <= 0) return;

    final unitRate =
        current.rates.convertBetween(
          fromCurrency: current.fromCurrency,
          toCurrency: current.toCurrency,
          amount: 1,
        ) ??
        (current.convertedAmount! / current.amount);

    final historyItem = ConversionHistoryModel.create(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      fromAmount: current.amount,
      toAmount: current.convertedAmount!,
      rate: unitRate,
    );
    await _repository.addHistory(historyItem);
  }

  /// Helper to push updated currency rate data to the Native Home Screen Widget.
  void _syncWidget(ConvertLoaded loadedState) {
    final unitRate = loadedState.rates.convertBetween(
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
