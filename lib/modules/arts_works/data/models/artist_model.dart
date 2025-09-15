class ArtistModel {
  final String id;
  final String name;
  final String? biography;
  final String? profileImageUrl;
  final String? style;
  final String? vision;
  final List<String> gallery;
  final DateTime? createdAt;

  ArtistModel({
    required this.id,
    required this.name,
    this.biography,
    this.profileImageUrl,
    this.style,
    this.vision,
    this.gallery = const [],
    this.createdAt,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      style: json['style'] as String?,
      vision: json['vision'] as String?,
      gallery: List<String>.from(json['gallery'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biography': biography,
      'profile_image_url': profileImageUrl,
      'style': style,
      'vision': vision,
      'gallery': gallery,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
