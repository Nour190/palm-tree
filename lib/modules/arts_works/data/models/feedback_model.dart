// lib/data/models/feedback_model.dart
class FeedbackModel {
  final String id;
  final String artworkId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  FeedbackModel({
    required this.id,
    required this.artworkId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      artworkId: json['artwork_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork_id': artworkId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
