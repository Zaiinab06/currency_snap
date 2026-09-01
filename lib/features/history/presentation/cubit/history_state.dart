import 'package:equatable/equatable.dart';
import '../../domain/entities/conversion_history_entity.dart';

/// Status representing the lifecycle of conversion history operations.
enum HistoryStatus { initial, loading, success, failure }

/// State managing the persisted conversion history logs.
class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ConversionHistoryEntity> history;
  final String? errorMessage;

  const HistoryState({
    required this.status,
    required this.history,
    this.errorMessage,
  });

  /// Initial state before history is loaded.
  factory HistoryState.initial() => const HistoryState(
        status: HistoryStatus.initial,
        history: [],
        errorMessage: null,
      );

  HistoryState copyWith({
    HistoryStatus? status,
    List<ConversionHistoryEntity>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, errorMessage];
}
