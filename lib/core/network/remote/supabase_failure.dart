abstract class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});
  @override
  String toString() => message;
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.msg = 'You are offline. Check your connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.msg = 'Request timed out. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause, super.stackTrace});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause, super.stackTrace});
}
