import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class EventsLocalDataSource {
  Future<void> cacheArtists(List<Artist> artists);
  Future<List<Artist>> getCachedArtists();

  Future<void> cacheArtworks(List<Artwork> artworks);
  Future<List<Artwork>> getCachedArtworks();

  Future<void> cacheSpeakers(List<Speaker> speakers);
  Future<List<Speaker>> getCachedSpeakers();

  Future<void> cacheWorkshops(List<Workshop> workshops);
  Future<List<Workshop>> getCachedWorkshops();

  Future<void> cacheEvents(List<Event> events);
  Future<List<Event>> getCachedEvents();

  Future<void> clearCache();
  Future<DateTime?> getLastSyncTime(String key);
  Future<void> setLastSyncTime(String key, DateTime time);
}

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  static const String _artistsBox = 'programs_artists_box';
  static const String _artworksBox = 'programs_artworks_box';
  static const String _speakersBox = 'programs_speakers_box';
  static const String _workshopsBox = 'programs_workshops_box';
  static const String _eventsBox = 'programs_events_box';
  static const String _metadataBox = 'metadata_box';

  @override
  Future<void> cacheArtists(List<Artist> artists) async {
    try {
      final box = Hive.box<Artist>(_artistsBox);
      await box.clear();

      for (var artist in artists) {
        await box.put(artist.id, artist);
      }

      await setLastSyncTime('artists', DateTime.now());
      debugPrint('[EventsLocalDS] Cached ${artists.length} artists');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error caching artists: $e');
    }
  }

  @override
  Future<List<Artist>> getCachedArtists() async {
    try {
      final box = Hive.box<Artist>(_artistsBox);
      final artists = box.values.toList();
      debugPrint('[EventsLocalDS] Retrieved ${artists.length} cached artists');
      return artists;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting cached artists: $e');
      return [];
    }
  }

  @override
  Future<void> cacheArtworks(List<Artwork> artworks) async {
    try {
      final box = Hive.box<Artwork>(_artworksBox);
      await box.clear();

      for (var artwork in artworks) {
        await box.put(artwork.id, artwork);
      }

      await setLastSyncTime('artworks', DateTime.now());
      debugPrint('[EventsLocalDS] Cached ${artworks.length} artworks');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error caching artworks: $e');
    }
  }

  @override
  Future<List<Artwork>> getCachedArtworks() async {
    try {
      final box = Hive.box<Artwork>(_artworksBox);
      final artworks = box.values.toList();
      debugPrint('[EventsLocalDS] Retrieved ${artworks.length} cached artworks');
      return artworks;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting cached artworks: $e');
      return [];
    }
  }

  @override
  Future<void> cacheSpeakers(List<Speaker> speakers) async {
    try {
      final box = Hive.box<Speaker>(_speakersBox);
      await box.clear();

      for (var speaker in speakers) {
        await box.put(speaker.id, speaker);
      }

      await setLastSyncTime('speakers', DateTime.now());
      debugPrint('[EventsLocalDS] Cached ${speakers.length} speakers');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error caching speakers: $e');
    }
  }

  @override
  Future<List<Speaker>> getCachedSpeakers() async {
    try {
      final box = Hive.box<Speaker>(_speakersBox);
      final speakers = box.values.toList();
      debugPrint('[EventsLocalDS] Retrieved ${speakers.length} cached speakers');
      return speakers;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting cached speakers: $e');
      return [];
    }
  }

  @override
  Future<void> cacheWorkshops(List<Workshop> workshops) async {
    try {
      final box = Hive.box<Workshop>(_workshopsBox);
      await box.clear();

      for (var workshop in workshops) {
        await box.put(workshop.id, workshop);
      }

      await setLastSyncTime('workshops', DateTime.now());
      debugPrint('[EventsLocalDS] Cached ${workshops.length} workshops');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error caching workshops: $e');
    }
  }

  @override
  Future<List<Workshop>> getCachedWorkshops() async {
    try {
      final box = Hive.box<Workshop>(_workshopsBox);
      final workshops = box.values.toList();
      debugPrint('[EventsLocalDS] Retrieved ${workshops.length} cached workshops');
      return workshops;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting cached workshops: $e');
      return [];
    }
  }

  @override
  Future<void> cacheEvents(List<Event> events) async {
    try {
      final box = Hive.box<Event>(_eventsBox);
      await box.clear();

      for (var event in events) {
        await box.put(event.id, event);
      }

      await setLastSyncTime('events', DateTime.now());
      debugPrint('[EventsLocalDS] Cached ${events.length} events');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error caching events: $e');
    }
  }

  @override
  Future<List<Event>> getCachedEvents() async {
    try {
      final box = Hive.box<Event>(_eventsBox);
      final events = box.values.toList();
      debugPrint('[EventsLocalDS] Retrieved ${events.length} cached events');
      return events;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting cached events: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Hive.box<Artist>(_artistsBox).clear();
      await Hive.box<Artwork>(_artworksBox).clear();
      await Hive.box<Speaker>(_speakersBox).clear();
      await Hive.box<Workshop>(_workshopsBox).clear();
      await Hive.box<Event>(_eventsBox).clear();
      debugPrint('[EventsLocalDS] Cache cleared');
    } catch (e) {
      debugPrint('[EventsLocalDS] Error clearing cache: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String key) async {
    try {
      final box = Hive.box(_metadataBox);
      final timestamp = box.get('last_sync_$key') as String?;
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      debugPrint('[EventsLocalDS] Error getting last sync time: $e');
      return null;
    }
  }

  @override
  Future<void> setLastSyncTime(String key, DateTime time) async {
    try {
      final box = Hive.box(_metadataBox);
      await box.put('last_sync_$key', time.toIso8601String());
    } catch (e) {
      debugPrint('[EventsLocalDS] Error setting last sync time: $e');
    }
  }
}
