// lib/modules/events/data/repositories/speaker/speaker_repository_impl.dart
import 'package:baseqat/modules/events/data/repositories/speaker/speaker_repository.dart';

import '../../datasources/speaker_remote_data_source.dart';

class SpeakerRepositoryImpl implements SpeakerRepository {
  final SpeakerRemoteDataSource _remote;
  SpeakerRepositoryImpl(this._remote);

  @override
  Future<bool> isSpeakerFavorite({
    required String userId,
    required String speakerId,
  }) => _remote.isFavorite(userId: userId, speakerId: speakerId);

  @override
  Future<bool> setSpeakerFavorite({
    required String userId,
    required String speakerId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      await _remote.setFavorite(
        userId: userId,
        speakerId: speakerId,
        value: value,
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
