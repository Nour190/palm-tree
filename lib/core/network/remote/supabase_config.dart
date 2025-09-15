// lib/core/network/remote/supabase_config.dart

import 'package:baseqat/core/resourses/constants_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseConfig is a utility class that handles Supabase initialization and client access.

class SupabaseConfig {
  /// Private constructor to prevent instantiation
  SupabaseConfig._();

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  /// Returns the initialized Supabase client instance.
  ///
  /// Must call [initialize] before accessing the client.
  ///
  /// Returns [SupabaseClient] instance for database operations.
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
  }
}
