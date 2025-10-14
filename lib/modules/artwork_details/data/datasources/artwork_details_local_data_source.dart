import 'package:hive_flutter/hive_flutter.dart';
import 'package:baseqat/core/database/hive_service.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/artwork_details/data/models/pending_feedback_model.dart';
import 'package:flutter/foundation.dart';

abstract class ArtworkDetailsLocalDataSource {
  Future<Artwork?> getArtworkById(String id);
  Future<void> saveArtwork(Artwork artwork);

  Future<Artist?> getArtistById(String id);
  Future<void> saveArtist(Artist artist);

  Future<List<Artwork>> getArtworksByArtistId(String artistId);
  Future<void> saveArtistArtworks(String artistId, List<Artwork> artworks);

  Future<void> savePendingFeedback(PendingFeedbackModel feedback);
  Future<List<PendingFeedbackModel>> getPendingFeedback();
  Future<void> markFeedbackAsSynced(String id);
  Future<void> deletePendingFeedback(String id);
}

class ArtworkDetailsLocalDataSourceImpl implements ArtworkDetailsLocalDataSource {
  @override
  Future<Artwork?> getArtworkById(String id) async {
    try {
      final box = Hive.box<Artwork>(HiveService.artworksBox);
      final artwork = box.get(id);
      debugPrint('[LocalDataSource] Retrieved artwork: ${artwork?.id}');
      return artwork;
    } catch (e) {
      debugPrint('[LocalDataSource] Error getting artwork: $e');
      return null;
    }
  }

  @override
  Future<void> saveArtwork(Artwork artwork) async {
    try {
      final box = Hive.box<Artwork>(HiveService.artworksBox);
      await box.put(artwork.id, artwork);
      debugPrint('[LocalDataSource] Saved artwork: ${artwork.id}');
    } catch (e) {
      debugPrint('[LocalDataSource] Error saving artwork: $e');
    }
  }

  @override
  Future<Artist?> getArtistById(String id) async {
    try {
      final box = Hive.box<Artist>(HiveService.artistsBox);
      final artist = box.get(id);
      debugPrint('[LocalDataSource] Retrieved artist: ${artist?.id}');
      return artist;
    } catch (e) {
      debugPrint('[LocalDataSource] Error getting artist: $e');
      return null;
    }
  }

  @override
  Future<void> saveArtist(Artist artist) async {
    try {
      final box = Hive.box<Artist>(HiveService.artistsBox);
      await box.put(artist.id, artist);
      debugPrint('[LocalDataSource] Saved artist: ${artist.id}');
    } catch (e) {
      debugPrint('[LocalDataSource] Error saving artist: $e');
    }
  }

  @override
  Future<List<Artwork>> getArtworksByArtistId(String artistId) async {
    try {
      final box = Hive.box<Artwork>(HiveService.artworksBox);
      final artworks = box.values.where((a) => a.artistId == artistId).toList();
      debugPrint('[LocalDataSource] Retrieved ${artworks.length} artworks for artist: $artistId');
      return artworks;
    } catch (e) {
      debugPrint('[LocalDataSource] Error getting artworks by artist: $e');
      return [];
    }
  }

  @override
  Future<void> saveArtistArtworks(String artistId, List<Artwork> artworks) async {
    try {
      final box = Hive.box<Artwork>(HiveService.artworksBox);
      for (final artwork in artworks) {
        await box.put(artwork.id, artwork);
      }
      debugPrint('[LocalDataSource] Saved ${artworks.length} artworks for artist: $artistId');
    } catch (e) {
      debugPrint('[LocalDataSource] Error saving artist artworks: $e');
    }
  }

  @override
  Future<void> savePendingFeedback(PendingFeedbackModel feedback) async {
    try {
      final box = Hive.box<PendingFeedbackModel>(HiveService.pendingFeedbackBox);
      await box.put(feedback.id, feedback);
      debugPrint('[LocalDataSource] ========== FEEDBACK SAVED ==========');
      debugPrint('[LocalDataSource] Saved pending feedback: ${feedback.id}');
      debugPrint('[LocalDataSource]   - Artwork ID: ${feedback.artworkId}');
      debugPrint('[LocalDataSource]   - Session ID: ${feedback.sessionId}');
      debugPrint('[LocalDataSource]   - Rating: ${feedback.rating}');
      debugPrint('[LocalDataSource]   - Message: ${feedback.message}');
      debugPrint('[LocalDataSource]   - Tags: ${feedback.tags}');
      debugPrint('[LocalDataSource]   - Synced: ${feedback.synced}');
      debugPrint('[LocalDataSource]   - Total items in box: ${box.length}');
    } catch (e) {
      debugPrint('[LocalDataSource] Error saving pending feedback: $e');
    }
  }

  @override
  Future<List<PendingFeedbackModel>> getPendingFeedback() async {
    try {
      final box = Hive.box<PendingFeedbackModel>(HiveService.pendingFeedbackBox);
      final allItems = box.values.toList();
      final pending = allItems.where((f) => !f.synced).toList();

      debugPrint('[LocalDataSource] ========== GET PENDING FEEDBACK ==========');
      debugPrint('[LocalDataSource] Total items in box: ${allItems.length}');
      debugPrint('[LocalDataSource] Unsynced items: ${pending.length}');

      for (var i = 0; i < pending.length; i++) {
        final item = pending[i];
        debugPrint('[LocalDataSource] Item ${i + 1}:');
        debugPrint('[LocalDataSource]   - ID: ${item.id}');
        debugPrint('[LocalDataSource]   - Artwork ID: ${item.artworkId}');
        debugPrint('[LocalDataSource]   - Session ID: ${item.sessionId}');
        debugPrint('[LocalDataSource]   - Rating: ${item.rating}');
        debugPrint('[LocalDataSource]   - Synced: ${item.synced}');
      }

      return pending;
    } catch (e) {
      debugPrint('[LocalDataSource] Error getting pending feedback: $e');
      return [];
    }
  }

  @override
  Future<void> markFeedbackAsSynced(String id) async {
    try {
      final box = Hive.box<PendingFeedbackModel>(HiveService.pendingFeedbackBox);
      final feedback = box.get(id);
      if (feedback != null) {
        await box.put(id, feedback.copyWith(synced: true));
        debugPrint('[LocalDataSource] Marked feedback as synced: $id');
      }
    } catch (e) {
      debugPrint('[LocalDataSource] Error marking feedback as synced: $e');
    }
  }

  @override
  Future<void> deletePendingFeedback(String id) async {
    try {
      final box = Hive.box<PendingFeedbackModel>(HiveService.pendingFeedbackBox);
      await box.delete(id);
      debugPrint('[LocalDataSource] ========== FEEDBACK DELETED ==========');
      debugPrint('[LocalDataSource] Deleted pending feedback: $id');
      debugPrint('[LocalDataSource] Remaining items in box: ${box.length}');
    } catch (e) {
      debugPrint('[LocalDataSource] Error deleting pending feedback: $e');
    }
  }
}
