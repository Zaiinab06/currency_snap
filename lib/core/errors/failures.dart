import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure representing server or remote API errors.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

/// Failure representing network connectivity or timeout errors.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Failure representing local cache or storage read/write errors.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

/// General or unexpected failure.
class GeneralFailure extends Failure {
  const GeneralFailure([super.message = 'An unexpected error occurred.']);
}
