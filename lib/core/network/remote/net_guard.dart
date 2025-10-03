import 'dart:async';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Throws [OfflineFailure] if there is no network.
Future<void> ensureOnline() async {
  final status = await Connectivity().checkConnectivity();
  if (status.contains(ConnectivityResult.none)) {
    throw  OfflineFailure();
  }
}

/// Max page size clamp to 10 (hard cap here).
int clampLimit(int? limit) =>
    (limit == null || limit <= 0) ? 10 : (limit > 10 ? 10 : limit);
