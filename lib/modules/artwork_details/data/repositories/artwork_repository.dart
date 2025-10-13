import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_local_data_source.dart';
import 'package:baseqat/modules/artwork_details/data/models/pending_feedback_model.dart';
import 'package:dartz/dartz.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Abstract contract
abstract class ArtworkDetailsRepository {
  // ----- Artworks / Artists / Feedback -----
  Future<Either<Failure, Artwork>> getArtworkById(String id);
  Future<Either<Failure, Artist>> getArtistById(String id);

  /// Upserts by default when a unique(artwork_id,session_id) exists.
  Future<Either<Failure, Unit>> submitFeedback({
    required String sessionId, // Changed from userId to sessionId
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists,
  });

  Future<void> syncPendingFeedback();
}

/// Implementation
class ArtworkDetailsRepositoryImpl implements ArtworkDetailsRepository {
  final ArtworkDetailsRemoteDataSource remote;
  final ArtworkDetailsLocalDataSource local;
  final ConnectivityService connectivity;

  ArtworkDetailsRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  // ----- Artworks / Artists / Feedback -----

  @override
  Future<Either<Failure, Artwork>> getArtworkById(String id) async {
    try {
      final hasConnection = await connectivity.hasConnection();

      if (hasConnection) {
        // Online: fetch from remote and cache
        try {
          final result = await remote.getArtworkById(id);
          // Cache the result
          await local.saveArtwork(result);
          debugPrint('[Repository] Fetched and cached artwork from remote: $id');
          return Right(result);
        } catch (e, st) {
          // If remote fails, try local
          debugPrint('[Repository] Remote fetch failed, trying local: $e');
          final localResult = await local.getArtworkById(id);
          if (localResult != null) {
            return Right(localResult);
          }
          return Left(mapError(e, st));
        }
      } else {
        // Offline: try local first
        debugPrint('[Repository] Offline mode - fetching from local');
        final localResult = await local.getArtworkById(id);
        if (localResult != null) {
          return Right(localResult);
        }
        return Left(CacheFailure(
          'No internet connection and no cached data available',
        ));
      }
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtistById(String id) async {
    try {
      final hasConnection = await connectivity.hasConnection();

      if (hasConnection) {
        // Online: fetch from remote and cache
        try {
          final result = await remote.getArtistById(id);
          // Cache the result
          await local.saveArtist(result);
          debugPrint('[Repository] Fetched and cached artist from remote: $id');
          return Right(result);
        } catch (e, st) {
          // If remote fails, try local
          debugPrint('[Repository] Remote fetch failed, trying local: $e');
          final localResult = await local.getArtistById(id);
          if (localResult != null) {
            return Right(localResult);
          }
          return Left(mapError(e, st));
        }
      } else {
        // Offline: try local first
        debugPrint('[Repository] Offline mode - fetching from local');
        final localResult = await local.getArtistById(id);
        if (localResult != null) {
          return Right(localResult);
        }
        return Left(CacheFailure(
          'No internet connection and no cached data available',
        ));
      }
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitFeedback({
    required String sessionId, // Changed from userId to sessionId
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists = true,
  }) async {
    try {
      final hasConnection = await connectivity.hasConnection();

      if (hasConnection) {
        // Online: submit directly
        try {
          await remote.submitFeedback(
            session_id: sessionId, // Using sessionId as userId
            artworkId: artworkId,
            rating: rating,
            message: message,
            tags: tags,
            upsertIfExists: upsertIfExists,
          );
          debugPrint('[Repository] Feedback submitted successfully');
          return const Right(unit);
        } catch (e, st) {
          // If submission fails, queue it
          debugPrint('[Repository] Remote submission failed, queuing: $e');
          await _queueFeedback(
            sessionId: sessionId,
            artworkId: artworkId,
            rating: rating,
            message: message,
            tags: tags,
          );
          return const Right(unit);
        }
      } else {
        // Offline: queue for later
        debugPrint('[Repository] Offline mode - queuing feedback');
        await _queueFeedback(
          sessionId: sessionId,
          artworkId: artworkId,
          rating: rating,
          message: message,
          tags: tags,
        );
        return const Right(unit);
      }
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  Future<void> _queueFeedback({
    required String sessionId,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
  }) async {
    final pendingFeedback = PendingFeedbackModel(
      id: const Uuid().v4(),
      sessionId: sessionId,
      artworkId: artworkId,
      rating: rating,
      message: message,
      tags: tags,
      createdAt: DateTime.now(),
      synced: false,
    );
    await local.savePendingFeedback(pendingFeedback);
    debugPrint('[Repository] Feedback queued: ${pendingFeedback.id}');
  }

  @override
  Future<void> syncPendingFeedback() async {
    try {
      debugPrint('[Repository] ========== SYNC PENDING FEEDBACK STARTED ==========');

      final hasConnection = await connectivity.hasConnection();
      if (!hasConnection) {
        debugPrint('[Repository] No connection - skipping sync');
        return;
      }

      debugPrint('[Repository] Connection available - fetching pending feedback');
      final pending = await local.getPendingFeedback();
      debugPrint('[Repository] Found ${pending.length} pending feedback items to sync');

      if (pending.isEmpty) {
        debugPrint('[Repository] No pending feedback to sync');
        return;
      }

      int successCount = 0;
      int failureCount = 0;

      for (final feedback in pending) {
        try {
          debugPrint('[Repository] Attempting to sync feedback: ${feedback.id}');
          debugPrint('[Repository]   - Artwork ID: ${feedback.artworkId}');
          debugPrint('[Repository]   - Session ID: ${feedback.sessionId}');
          debugPrint('[Repository]   - Rating: ${feedback.rating}');
          debugPrint('[Repository]   - Message: ${feedback.message}');
          debugPrint('[Repository]   - Tags: ${feedback.tags}');
          debugPrint('[Repository]   - Created At: ${feedback.createdAt}');
          debugPrint('[Repository]   - Synced: ${feedback.synced}');

          await remote.submitFeedback(
            session_id: feedback.sessionId,
            artworkId: feedback.artworkId,
            rating: feedback.rating,
            message: feedback.message,
            tags: feedback.tags,
            upsertIfExists: true,
          );

          await local.deletePendingFeedback(feedback.id);
          debugPrint('[Repository] ✓ Successfully synced and deleted feedback: ${feedback.id}');
          successCount++;
        } catch (e) {
          debugPrint('[Repository] ✗ Failed to sync feedback ${feedback.id}: $e');
          failureCount++;
          // Continue with next item
        }
      }

      debugPrint('[Repository] ========== SYNC COMPLETED ==========');
      debugPrint('[Repository] Success: $successCount, Failed: $failureCount');
    } catch (e) {
      debugPrint('[Repository] ========== SYNC ERROR ==========');
      debugPrint('[Repository] Error during sync: $e');
    }
  }
}
