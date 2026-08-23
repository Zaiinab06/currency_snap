import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/favourite_pair_model.dart';
import '../../data/repositories/currency_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import 'convert_state.dart';

/// Cubit managing currency conversion state and rate updates.
class ConvertCubit extends Cubit<ConvertState> {
  final CurrencyRepository _repository;

  ConvertCubit(this._repository) : super(const ConvertInitial());

  /// Loads exchange rates for [baseCurrency] and calculates converted amount.
  Future<void> loadRates({
    String baseCurrency = AppConstants.defaultBaseCurrency,
    String targetCurrency = AppConstants.defaultTargetCurrency,
    double amount = 100,
  }) async {
    emit(const ConvertLoading());
    try {
      final result = await _repository.getRates(baseCurrency);
      final converted = result.rates.convert(
        targetCurrency: targetCurrency,
        amount: amount,
      );

      emit(
        ConvertLoaded(
          rates: result.rates,
          isFromCache: result.isFromCache,
          fromCurrency: baseCurrency,
          toCurrency: targetCurrency,
          amount: amount,
          convertedAmount: converted,
        ),
      );
    } on NoCachedDataException catch (e) {
      emit(ConvertError(e.message));
    } catch (e) {
      emit(const ConvertError('Something went wrong. Please try again.'));
    }
  }

  /// Updates the conversion for a newly specified [newAmount].
  void updateAmount(double newAmount) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convert(
      targetCurrency: current.toCurrency,
      amount: newAmount,
    );

    emit(current.copyWith(amount: newAmount, convertedAmount: converted));
  }

  /// Swaps base and target currencies and reloads rates.
  Future<void> swapCurrencies() async {
    final current = state;
    if (current is! ConvertLoaded) return;

    await loadRates(
      baseCurrency: current.toCurrency,
      targetCurrency: current.fromCurrency,
      amount: current.amount,
    );
  }

  /// Changes the base currency and reloads rates.
  Future<void> changeBaseCurrency(String newBaseCurrency) async {
    final current = state;
    final target =
        current is ConvertLoaded
            ? current.toCurrency
            : AppConstants.defaultTargetCurrency;
    final amount = current is ConvertLoaded ? current.amount : 100.0;

    await loadRates(
      baseCurrency: newBaseCurrency,
      targetCurrency: target,
      amount: amount,
    );
  }

  /// Changes the target currency and recalculates the converted amount.
  void changeTargetCurrency(String newTargetCurrency) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convert(
      targetCurrency: newTargetCurrency,
      amount: current.amount,
    );

    emit(
      current.copyWith(
        toCurrency: newTargetCurrency,
        convertedAmount: converted,
      ),
    );
  }

  /// Saves the current currency pair to favorites.
  Future<void> saveCurrentPairToFavorites() async {
    final current = state;
    if (current is! ConvertLoaded) return;

    final rate = current.rates.rates[current.toCurrency];
    if (rate == null) return;

    final pair = FavoritePairModel.create(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      rate: rate,
    );
    await _repository.addFavorite(pair);
  }
}
