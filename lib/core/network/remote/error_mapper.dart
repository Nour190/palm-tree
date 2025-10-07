import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Failure mapError(Object e, StackTrace st) {
  if (e is Failure) return e;
  if (e is TimeoutException) return TimeoutFailure('errors.request_timed_out'.tr());

  if (e is PostgrestException) {
    final code = e.code ?? '';
    final msg = ( e.message.isNotEmpty)
        ? e.message
        : 'errors.request_failed'.tr();

    if (code == 'PGRST116' || code == 'PGRST204') {
      return NotFoundFailure('errors.resource_not_found'.tr());
    }
    if (code == 'PGRST101') {
      return OfflineFailure('errors.you_are_offline'.tr());
    }
    if (code == 'PGRST102') {
      return TimeoutFailure('errors.request_timed_out'.tr());
    }

    return NetworkFailure(msg, cause: e, stackTrace: st);
  }

  return UnknownFailure('errors.unexpected_error'.tr(), cause: e, stackTrace: st);
}
