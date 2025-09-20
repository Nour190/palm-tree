import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

/// Abstract contract
abstract class ArtworkDetailsRepository {
  // ----- Artworks / Artists / Feedback -----
  Future<Either<Failure, Artwork>> getArtworkById(String id);
  Future<Either<Failure, Artist>> getArtistById(String id);

  /// Upserts by default when a unique(artwork_id,user_id) exists.
  Future<Either<Failure, Unit>> submitFeedback({
    required String userId,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists, // <-- added
  });
}

/// Implementation
class ArtworkDetailsRepositoryImpl implements ArtworkDetailsRepository {
  final ArtworkDetailsRemoteDataSource remote;
  ArtworkDetailsRepositoryImpl({required this.remote});

  // ----- Artworks / Artists / Feedback -----

  @override
  Future<Either<Failure, Artwork>> getArtworkById(String id) async {
    try {
      final result = await remote.getArtworkById(id);
      return Right(result);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtistById(String id) async {
    try {
      final result = await remote.getArtistById(id);
      return Right(result);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitFeedback({
    required String userId,
    required String artworkId,
    required int rating,
    required String message,
    required List<String> tags,
    bool upsertIfExists = true, // <-- default aligns with remote
  }) async {
    try {
      await remote.submitFeedback(
        userId: userId,
        artworkId: artworkId,
        rating: rating,
        message: message,
        tags: tags,
        upsertIfExists: upsertIfExists,
      );
      return const Right(unit);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }
}
