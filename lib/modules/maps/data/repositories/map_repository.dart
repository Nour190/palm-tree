// lib/modules/events/domain/repositories/map_repository.dart
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

abstract class MapRepository {
  Future<List<Artist>> getArtists({int limit = 20});
  Future<List<Speaker>> getSpeakers({int limit = 20});
}
