import 'package:baseqat/modules/arts_works/data/data_sources/remote/artwork_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import '../models/artwork_model.dart';
import '../models/artist_model.dart';
import '../models/location_model.dart';
import '../models/feedback_model.dart';

abstract class ArtworkRepository {
  Future<Either<String, List<ArtworkModel>>> getArtworks();
  Future<Either<String, ArtworkModel?>> getArtworkById(String id);
  Future<Either<String, ArtistModel?>> getArtistById(String id);
  Future<Either<String, LocationModel?>> getLocationById(String id);
  Future<Either<String, List<FeedbackModel>>> getFeedbacksByArtworkId(
    String artworkId,
  );
  Future<Either<String, List<Map<String, dynamic>>>> getArtworksWithDetails();
  Future<Either<String, List<ArtworkModel>>> searchArtworks(String query);
  Future<Either<String, List<ArtworkModel>>> getArtworksByArtist(
    String artistId,
  );
  Future<Either<String, List<ArtworkModel>>> getArtworksForSale();
}

class ArtworkRepositoryImpl implements ArtworkRepository {
  final ArtworkRemoteDataSource remoteDataSource;

  ArtworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<ArtworkModel>>> getArtworks() async {
    try {
      final artworks = await remoteDataSource.getArtworks();
      return Right(artworks);
    } catch (e) {
      return Left('Failed to load artworks: $e');
    }
  }

  @override
  Future<Either<String, ArtworkModel?>> getArtworkById(String id) async {
    try {
      final artwork = await remoteDataSource.getArtworkById(id);
      return Right(artwork);
    } catch (e) {
      return Left('Failed to load artwork: $e');
    }
  }

  @override
  Future<Either<String, ArtistModel?>> getArtistById(String id) async {
    try {
      final artist = await remoteDataSource.getArtistById(id);
      return Right(artist);
    } catch (e) {
      return Left('Failed to load artist: $e');
    }
  }

  @override
  Future<Either<String, LocationModel?>> getLocationById(String id) async {
    try {
      final location = await remoteDataSource.getLocationById(id);
      return Right(location);
    } catch (e) {
      return Left('Failed to load location: $e');
    }
  }

  @override
  Future<Either<String, List<FeedbackModel>>> getFeedbacksByArtworkId(
    String artworkId,
  ) async {
    try {
      final feedbacks = await remoteDataSource.getFeedbacksByArtworkId(
        artworkId,
      );
      return Right(feedbacks);
    } catch (e) {
      return Left('Failed to load feedbacks: $e');
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>>
  getArtworksWithDetails() async {
    try {
      final artworksWithDetails = await remoteDataSource
          .getArtworksWithDetails();
      return Right(artworksWithDetails);
    } catch (e) {
      return Left('Failed to load artworks with details: $e');
    }
  }

  @override
  Future<Either<String, List<ArtworkModel>>> searchArtworks(
    String query,
  ) async {
    try {
      final artworks = await remoteDataSource.searchArtworks(query);
      return Right(artworks);
    } catch (e) {
      return Left('Failed to search artworks: $e');
    }
  }

  @override
  Future<Either<String, List<ArtworkModel>>> getArtworksByArtist(
    String artistId,
  ) async {
    try {
      final artworks = await remoteDataSource.getArtworksByArtist(artistId);
      return Right(artworks);
    } catch (e) {
      return Left('Failed to load artworks by artist: $e');
    }
  }

  @override
  Future<Either<String, List<ArtworkModel>>> getArtworksForSale() async {
    try {
      final artworks = await remoteDataSource.getArtworksForSale();
      return Right(artworks);
    } catch (e) {
      return Left('Failed to load artworks for sale: $e');
    }
  }
}
