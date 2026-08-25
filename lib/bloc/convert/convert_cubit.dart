import 'package:currency_snap/data/models/favourite_pair_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/currency_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import 'convert_state.dart';

/// Drives the Home/Converter screen.
///
/// Rates are fetched once for a fixed anchor currency (see
/// [AppConstants.defaultBaseCurrency]) and cached. Every subsequent
/// currency change — swap, picking a new "from", or a new "to" — is
/// pure client-side cross-rate math against that same rate table.
/// This avoids re-fetching (and re-hitting the offline/CORS fallback)
/// on every interaction, and prevents the from/to mismatch bug that
/// happens when a fallback-to-cache returns a different base than the
/// one just requested.
class ConvertCubit extends Cubit<ConvertState> {
  final CurrencyRepository _repository;

  ConvertCubit(this._repository) : super(const ConvertInitial());

  /// Refreshes exchange rates by triggering a fresh network call,
  /// animating the refresh indicator and updating the sync timestamp.
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

  /// Fetches the anchor rate table once (live, falling back to cache
  /// on failure) and sets up the initial from/to pair.
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

      emit(
        ConvertLoaded(
          rates: result.rates,
          isFromCache: result.isFromCache,
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          amount: amount,
          convertedAmount: converted,
          isRefreshing: false,
          lastSyncTime: result.syncTime,
        ),
      );
    } on NoCachedDataException catch (e) {
      emit(ConvertError(e.message));
    } catch (e) {
      emit(const ConvertError('Something went wrong. Please try again.'));
    }
  }

  /// Recalculates the converted amount for a new input amount.
  /// Pure math — no network call.
  void updateAmount(double newAmount) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convertBetween(
      fromCurrency: current.fromCurrency,
      toCurrency: current.toCurrency,
      amount: newAmount,
    );

    emit(current.copyWith(amount: newAmount, convertedAmount: converted));
  }

  /// Swaps "from" and "to" and recalculates. Pure math — no network call.
  void swapCurrencies() {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convertBetween(
      fromCurrency: current.toCurrency,
      toCurrency: current.fromCurrency,
      amount: current.amount,
    );

    emit(
      current.copyWith(
        fromCurrency: current.toCurrency,
        toCurrency: current.fromCurrency,
        convertedAmount: converted,
      ),
    );
  }

  /// Changes the source ("you send") currency and recalculates.
  /// Pure math — no network call.
  void changeSourceCurrency(String newSourceCurrency) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convertBetween(
      fromCurrency: newSourceCurrency,
      toCurrency: current.toCurrency,
      amount: current.amount,
    );

    emit(
      current.copyWith(
        fromCurrency: newSourceCurrency,
        convertedAmount: converted,
      ),
    );
  }

  /// Changes the target ("they receive") currency and recalculates.
  /// Pure math — no network call.
  void changeTargetCurrency(String newTargetCurrency) {
    final current = state;
    if (current is! ConvertLoaded) return;

    final converted = current.rates.convertBetween(
      fromCurrency: current.fromCurrency,
      toCurrency: newTargetCurrency,
      amount: current.amount,
    );

    emit(
      current.copyWith(
        toCurrency: newTargetCurrency,
        convertedAmount: converted,
      ),
    );
  }

  /// Saves the currently displayed pair to favorites, storing the
  /// live cross-rate for that specific pair.
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
}
