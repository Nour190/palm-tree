import 'package:baseqat/core/network/remote/supabase_failure.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:dartz/dartz.dart';

abstract class MuseumsRepository {
  Future<Either<Failure, List<Museum>>> getMuseums({int limit = 10});
  Future<Either<Failure, Museum?>> getMuseumById(String museumId);
}
