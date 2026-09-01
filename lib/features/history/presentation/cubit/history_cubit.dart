import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conversion_history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_state.dart';

/// Cubit managing conversion history with real-time reactive streaming from [HistoryRepository].
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _historyRepository;
  StreamSubscription<List<ConversionHistoryEntity>>? _streamSubscription;

  HistoryCubit(this._historyRepository) : super(HistoryState.initial()) {
    _streamSubscription =
        _historyRepository.historyStream.listen((updatedList) {
      emit(state.copyWith(
        status: HistoryStatus.success,
        history: updatedList,
        errorMessage: null,
      ));
    });
    loadHistory();
  }

  /// Loads all saved conversion history logs from local storage.
  Future<void> loadHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final items = await _historyRepository.getHistory();
      emit(state.copyWith(
        status: HistoryStatus.success,
        history: items,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: 'Failed to load conversion history.',
      ));
    }
  }

  /// Deletes a specific history item by ID.
  Future<void> deleteItem(String id) async {
    try {
      await _historyRepository.deleteHistoryItem(id);
      await loadHistory();
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: 'Failed to delete conversion log.',
      ));
    }
  }

  /// Clears all saved conversion history logs.
  Future<void> clearHistory() async {
    try {
      await _historyRepository.clearHistory();
      await loadHistory();
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: 'Failed to clear conversion history.',
      ));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
