class PendingFeedbackModel {
  final String id; // local ID
  final String sessionId; // replaces userId
  final String artworkId;
  final int rating;
  final String message;
  final List<String> tags;
  final DateTime createdAt;
  final bool synced;

  PendingFeedbackModel({
    required this.id,
    required this.sessionId,
    required this.artworkId,
    required this.rating,
    required this.message,
    required this.tags,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': sessionId,
      'artwork_id': artworkId,
      'rating': rating,
      'message': message,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory PendingFeedbackModel.fromMap(Map<String, dynamic> map) {
    return PendingFeedbackModel(
      id: map['id'] as String,
      sessionId: map['user_id'] as String,
      artworkId: map['artwork_id'] as String,
      rating: map['rating'] as int,
      message: map['message'] as String,
      tags: List<String>.from(map['tags'] as List),
      createdAt: DateTime.parse(map['created_at'] as String),
      synced: map['synced'] as bool? ?? false,
    );
  }

  PendingFeedbackModel copyWith({
    String? id,
    String? sessionId,
    String? artworkId,
    int? rating,
    String? message,
    List<String>? tags,
    DateTime? createdAt,
    bool? synced,
  }) {
    return PendingFeedbackModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      artworkId: artworkId ?? this.artworkId,
      rating: rating ?? this.rating,
      message: message ?? this.message,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }
}
