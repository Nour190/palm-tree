import 'package:easy_localization/easy_localization.dart';

abstract class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  Failure(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => message;
}

class OfflineFailure extends Failure {
  OfflineFailure([String? msg])
      : super(msg ?? 'errors.offline_failure'.tr());
}

class TimeoutFailure extends Failure {
  TimeoutFailure([String? msg]) : super(msg ?? 'errors.timeout_error'.tr());
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message, {super.cause, super.stackTrace});
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  UnknownFailure(super.message, {super.cause, super.stackTrace});
}

class CacheFailure extends Failure {
  CacheFailure([String? msg])
      : super(msg ?? 'errors.cache_failure'.tr());
}

