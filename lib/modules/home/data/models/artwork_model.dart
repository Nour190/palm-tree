class Artwork {
  final String id;

  // EN
  final String name;
  final String? description;
  final String? materials;
  final String? vision;

  // AR
  final String? nameAr;
  final String? descriptionAr;
  final String? materialsAr;
  final String? visionAr;

  // Media
  final List<String> gallery;

  // Denormalized (optional)
  final String? artistId;
  final String? artistName;
  final String? artistNameAr;
  final String? artistProfileImage;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Artwork({
    required this.id,
    required this.name,
    this.description,
    this.materials,
    this.vision,
    this.nameAr,
    this.descriptionAr,
    this.materialsAr,
    this.visionAr,
    this.gallery = const [],
    this.artistId,
    this.artistName,
    this.artistNameAr,
    this.artistProfileImage,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------- Localized helpers ----------------
  String localizedName({required bool isRTL}) {
    final ar = (nameAr ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return name;
  }

  String? localizedDescription({required bool isRTL}) {
    final ar = (descriptionAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : description;
  }

  String? localizedMaterials({required bool isRTL}) {
    final ar = (materialsAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : materials;
  }

  String? localizedVision({required bool isRTL}) {
    final ar = (visionAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : vision;
  }

  String? localizedArtistName({required bool isRTL}) {
    final ar = (artistNameAr ?? '').trim();
    final en = (artistName ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  // ---------------- Mapping ----------------
  factory Artwork.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toUtc();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
      if (v is String && v.trim().isNotEmpty) return DateTime.parse(v).toUtc();
      return null;
    }

    List<String> _stringList(dynamic v) {
      if (v == null) return const <String>[];
      if (v is List) {
        return v.where((e) => e != null).map((e) => e.toString()).toList(growable: false);
      }
      return const <String>[];
    }

    return Artwork(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      materials: map['materials'] as String?,
      vision: map['vision'] as String?,

      nameAr: map['name_ar'] as String?,
      descriptionAr: map['description_ar'] as String?,
      materialsAr: map['materials_ar'] as String?,
      visionAr: map['vision_ar'] as String?,

      gallery: _stringList(map['gallery']),
      artistId: map['artist_id'] as String?,
      artistName: map['artist_name'] as String?,
      artistNameAr: map['artist_name_ar'] as String?,
      artistProfileImage: map['artist_profile_image'] as String?,

      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // EN
      'name': name,
      'description': description,
      'materials': materials,
      'vision': vision,
      // AR
      'name_ar': nameAr,
      'description_ar': descriptionAr,
      'materials_ar': materialsAr,
      'vision_ar': visionAr,
      // Media
      'gallery': gallery,
      // FK (usually only artist_id on writes)
      'artist_id': artistId,
    };
  }
}
