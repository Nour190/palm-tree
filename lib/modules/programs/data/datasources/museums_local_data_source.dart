import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class MuseumsLocalDataSource {
  Future<void> cacheMuseums(List<Museum> museums);
  Future<List<Museum>> getCachedMuseums();
  Future<void> clearCache();
  Future<DateTime?> getLastSyncTime(String key);
  Future<void> setLastSyncTime(String key, DateTime time);
}

class MuseumsLocalDataSourceImpl implements MuseumsLocalDataSource {
  static const String _museumsBox = 'programs_museums_box';
  static const String _metadataBox = 'metadata_box';

  @override
  Future<void> cacheMuseums(List<Museum> museums) async {
    try {
      final box = Hive.box<Museum>(_museumsBox);
      await box.clear();

      for (var museum in museums) {
        await box.put(museum.id, museum);
      }

      await setLastSyncTime('museums', DateTime.now());
      debugPrint('[MuseumsLocalDS] Cached ${museums.length} museums');
    } catch (e) {
      debugPrint('[MuseumsLocalDS] Error caching museums: $e');
    }
  }

  @override
  Future<List<Museum>> getCachedMuseums() async {
    try {
      final box = Hive.box<Museum>(_museumsBox);
      final museums = box.values.toList();
      debugPrint('[MuseumsLocalDS] Retrieved ${museums.length} cached museums');
      return museums;
    } catch (e) {
      debugPrint('[MuseumsLocalDS] Error getting cached museums: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Hive.box<Museum>(_museumsBox).clear();
      debugPrint('[MuseumsLocalDS] Cache cleared');
    } catch (e) {
      debugPrint('[MuseumsLocalDS] Error clearing cache: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String key) async {
    try {
      final box = Hive.box(_metadataBox);
      final timestamp = box.get('last_sync_$key') as String?;
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      debugPrint('[MuseumsLocalDS] Error getting last sync time: $e');
      return null;
    }
  }

  @override
  Future<void> setLastSyncTime(String key, DateTime time) async {
    try {
      final box = Hive.box(_metadataBox);
      await box.put('last_sync_$key', time.toIso8601String());
    } catch (e) {
      debugPrint('[MuseumsLocalDS] Error setting last sync time: $e');
    }
  }
}
