import 'package:hive_flutter/hive_flutter.dart';
import 'package:baseqat/core/database/hive_service.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';

abstract class HomeLocalDataSource {
  Future<void> cacheArtists(List<Artist> artists);
  Future<List<Artist>> getCachedArtists();

  Future<void> cacheArtworks(List<Artwork> artworks);
  Future<List<Artwork>> getCachedArtworks();

  Future<void> cacheInfo(InfoModel info);
  Future<InfoModel?> getCachedInfo();

  Future<void> cacheReviews(List<ReviewModel> reviews);
  Future<List<ReviewModel>> getCachedReviews();

  Future<void> clearAllCache();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const String _artistsOrderKey = '_artists_order';
  static const String _artworksOrderKey = '_artworks_order';
  static const String _reviewsOrderKey = '_reviews_order';

  @override
  Future<void> cacheArtists(List<Artist> artists) async {
    final box = Hive.box<Artist>(HiveService.artistsBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = <String>[];
    final seenIds = <String>{};

    for (final artist in artists) {
      if (!seenIds.contains(artist.id)) {
        await box.put(artist.id, artist);
        orderList.add(artist.id);
        seenIds.add(artist.id);
      }
    }

    final keysToRemove = box.keys.where((key) => !seenIds.contains(key)).toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }

    await metadataBox.put(_artistsOrderKey, orderList);
  }

  @override
  Future<List<Artist>> getCachedArtists() async {
    final box = Hive.box<Artist>(HiveService.artistsBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = metadataBox.get(_artistsOrderKey) as List<dynamic>?;
    if (orderList == null || orderList.isEmpty) {
      return box.values.where((v) => v is Artist).cast<Artist>().toList();
    }

    final result = <Artist>[];
    final seenIds = <String>{};

    for (final id in orderList) {
      final idStr = id.toString();
      if (!seenIds.contains(idStr)) {
        final artist = box.get(idStr);
        if (artist != null && artist is Artist) {
          result.add(artist);
          seenIds.add(idStr);
        }
      }
    }
    return result;
  }

  @override
  Future<void> cacheArtworks(List<Artwork> artworks) async {
    final box = Hive.box<Artwork>(HiveService.artworksBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = <String>[];
    final seenIds = <String>{};

    for (final artwork in artworks) {
      if (!seenIds.contains(artwork.id)) {
        await box.put(artwork.id, artwork);
        orderList.add(artwork.id);
        seenIds.add(artwork.id);
      }
    }

    final keysToRemove = box.keys.where((key) => !seenIds.contains(key)).toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }

    await metadataBox.put(_artworksOrderKey, orderList);
  }

  @override
  Future<List<Artwork>> getCachedArtworks() async {
    final box = Hive.box<Artwork>(HiveService.artworksBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = metadataBox.get(_artworksOrderKey) as List<dynamic>?;
    if (orderList == null || orderList.isEmpty) {
      return box.values.where((v) => v is Artwork).cast<Artwork>().toList();
    }

    final result = <Artwork>[];
    final seenIds = <String>{};

    for (final id in orderList) {
      final idStr = id.toString();
      if (!seenIds.contains(idStr)) {
        final artwork = box.get(idStr);
        if (artwork != null && artwork is Artwork) {
          result.add(artwork);
          seenIds.add(idStr);
        }
      }
    }
    return result;
  }

  @override
  Future<void> cacheInfo(InfoModel info) async {
    final box = Hive.box<InfoModel>(HiveService.infoBox);
    await box.put('info', info);
  }

  @override
  Future<InfoModel?> getCachedInfo() async {
    final box = Hive.box<InfoModel>(HiveService.infoBox);
    return box.get('info');
  }

  @override
  Future<void> cacheReviews(List<ReviewModel> reviews) async {
    final box = Hive.box<ReviewModel>(HiveService.reviewsBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = <String>[];

    for (var i = 0; i < reviews.length; i++) {
      final key = 'review_$i';
      await box.put(key, reviews[i]);
      orderList.add(key);
    }

    final keysToRemove = box.keys.where((key) => !orderList.contains(key)).toList();
    for (final key in keysToRemove) {
      await box.delete(key);
    }

    await metadataBox.put(_reviewsOrderKey, orderList);
  }

  @override
  Future<List<ReviewModel>> getCachedReviews() async {
    final box = Hive.box<ReviewModel>(HiveService.reviewsBox);
    final metadataBox = Hive.box(HiveService.metadataBox);

    final orderList = metadataBox.get(_reviewsOrderKey) as List<dynamic>?;
    if (orderList == null || orderList.isEmpty) {
      return box.values.where((v) => v is ReviewModel).cast<ReviewModel>().toList();
    }

    final result = <ReviewModel>[];

    for (final key in orderList) {
      final keyStr = key.toString();
      final review = box.get(keyStr);
      if (review != null && review is ReviewModel) {
        result.add(review);
      }
    }
    return result;
  }

  @override
  Future<void> clearAllCache() async {
    await HiveService.clearAllData();
  }
}
