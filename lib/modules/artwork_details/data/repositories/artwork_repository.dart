import 'package:baseqat/core/network/remote/error_mapper.dart';
import 'package:baseqat/modules/artwork_details/data/datasources/artwork_details_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';

// Chat models
import 'package:baseqat/modules/artwork_details/data/models/chat_models.dart';

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

  // ----- Chat -----
  Future<Either<Failure, List<ChatMessage>>> getChatHistory({
    required String artworkId,
    required String userId,
    int limit,
  });

  /// Realtime: emits full list for that (artworkId,userId) ordered oldest → newest.
  /// Errors are mapped to Failure and rethrown on the stream.
  Stream<List<ChatMessage>> watchChat({
    required String artworkId,
    required String userId,
  });

  Future<Either<Failure, ChatMessage>> sendChatMessage({
    required String artworkId,
    required String userId,
    String? text,
    List<UploadBlob> files,
  });

  Future<Either<Failure, List<ChatAttachment>>> uploadFiles({
    required String artworkId,
    required String userId,
    required List<UploadBlob> files,
    bool useSignedUrls,
    Duration signedUrlTTL,
  });

  Future<Either<Failure, Unit>> deleteMessage({
    required String messageId,
    required String userId,
  });

  Future<Either<Failure, Unit>> deleteAttachment({required String storagePath});
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

  // ----- Chat -----

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory({
    required String artworkId,
    required String userId,
    int limit = 50,
  }) async {
    try {
      final list = await remote.getChatHistory(
        artworkId: artworkId,
        userId: userId,
        limit: limit,
      );
      return Right(list);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Stream<List<ChatMessage>> watchChat({
    required String artworkId,
    required String userId,
  }) {
    // Map errors into Failure on the stream (consumer can catch)
    return remote.watchChat(artworkId: artworkId, userId: userId).handleError((
      e,
      st,
    ) {
      throw mapError(e, st);
    });
  }

  @override
  Future<Either<Failure, ChatMessage>> sendChatMessage({
    required String artworkId,
    required String userId,
    String? text,
    List<UploadBlob> files = const [],
  }) async {
    try {
      final msg = await remote.sendChatMessage(
        artworkId: artworkId,
        userId: userId,
        text: text,
        files: files,
      );
      return Right(msg);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, List<ChatAttachment>>> uploadFiles({
    required String artworkId,
    required String userId,
    required List<UploadBlob> files,
    bool useSignedUrls = false,
    Duration signedUrlTTL = const Duration(hours: 1),
  }) async {
    try {
      final atts = await remote.uploadFiles(
        artworkId: artworkId,
        userId: userId,
        files: files,
        useSignedUrls: useSignedUrls,
        signedUrlTTL: signedUrlTTL,
      );
      return Right(atts);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      await remote.deleteMessage(messageId: messageId, userId: userId);
      return const Right(unit);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAttachment({
    required String storagePath,
  }) async {
    try {
      await remote.deleteAttachment(storagePath: storagePath);
      return const Right(unit);
    } catch (e, st) {
      return Left(mapError(e, st));
    }
  }
}
