import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      // Check if any connection type is available
      final hasConnection = result.any((connectivityResult) =>
          connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet);
      
      debugPrint('[ConnectivityService] Connection status: $hasConnection');
      return hasConnection;
    } catch (e) {
      debugPrint('[ConnectivityService] Error checking connectivity: $e');
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
