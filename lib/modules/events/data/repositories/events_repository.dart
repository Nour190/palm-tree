import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:dartz/dartz.dart';

import '../models/gallery_item.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<Artist>>> getArtists({int limit = 10});
  Future<Either<Failure, List<Artwork>>> getArtworks({int limit = 10});
  Future<Either<Failure, List<Speaker>>> getSpeakers({int limit = 10});
  Future<Either<Failure, List<GalleryItem>>> getGalleryFromArtists({
    int limitArtists = 10,
  });
}
