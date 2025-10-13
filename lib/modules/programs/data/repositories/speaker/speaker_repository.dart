// lib/modules/events/data/repositories/speaker/speaker_repository.dart
abstract class SpeakerRepository {
  Future<bool> isSpeakerFavorite({
    required String userId,
    required String speakerId,
  });

  Future<bool> setSpeakerFavorite({
    required String userId,
    required String speakerId,
    required bool value,
    String? title,
    String? description,
    String? imageUrl,
  });
}
