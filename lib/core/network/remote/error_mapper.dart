import 'dart:async';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Failure mapError(Object e, StackTrace st) {
  if (e is Failure) return e;
  if (e is TimeoutException) return const TimeoutFailure();
  if (e is PostgrestException) {
    final code = e.code ?? '';
    final msg = (e.message.isNotEmpty) ? e.message : 'Request failed';

    if (code == 'PGRST116' || code == 'PGRST204') {
      return NotFoundFailure('Resource not found');
    }
    if (code == 'PGRST101') {
      return OfflineFailure('You are offline. Check your connection.');
    }
    if (code == 'PGRST102') {
      return TimeoutFailure('Request timed out. Please try again.');
    }

    return NetworkFailure(msg, cause: e, stackTrace: st);
  }

  return UnknownFailure('Unexpected error', cause: e, stackTrace: st);
}
