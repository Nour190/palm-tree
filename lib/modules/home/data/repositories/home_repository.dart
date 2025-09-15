import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Artist>>> getArtists({
    int? limit,
    int offset = 0,
  });
  Future<Either<Failure, List<Artwork>>> getArtworks({
    int? limit,
    int offset = 0,
  });
  Future<Either<Failure, InfoModel>> getInfo();
}
