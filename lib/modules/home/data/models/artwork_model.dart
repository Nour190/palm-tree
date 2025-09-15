// ======================= Artwork =======================
class Artwork {
  final String id;
  final String name;
  final String? description;
  final String? materials;
  final String? vision;
  final List<String> gallery;

  // Link to Artist (optional in data)
  final String? artistId;
  final String? artistName; // denormalized convenience
  final String? artistProfileImage; // denormalized convenience

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Artwork({
    required this.id,
    required this.name,
    this.description,
    this.materials,
    this.vision,
    this.gallery = const [],
    this.artistId,
    this.artistName,
    this.artistProfileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Artwork.fromMap(Map<String, dynamic> map) {
    return Artwork(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      materials: map['materials'] as String?,
      vision: map['vision'] as String?,
      gallery: List<String>.from(map['gallery'] ?? const []),
      artistId: map['artist_id'] as String?,
      artistName: map['artist_name'] as String?,
      artistProfileImage: map['artist_profile_image'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at']).toUtc()
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at']).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'materials': materials,
      'vision': vision,
      'gallery': gallery,
      'artist_id': artistId,
      'artist_name': artistName,
      'artist_profile_image': artistProfileImage,
    };
  }
}
