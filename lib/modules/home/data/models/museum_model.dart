class Museum {
  final String id;
  
  // Basic info
  final String museumName;
  final String? museumNameAr;
  final String? description;
  final String? descriptionAr;
  
  // Media
  final String? coverImage;
  
  // Location
  final String location;
  final double? latitude;
  final double? longitude;
  
  // Relations
  final List<String> artworkTypes; // List of artwork type names
  final List<String> artistIds; // Array of artist IDs
  
  // Status
  final String status; // draft, planned, published, cancelled
  
  // Metadata
  final Map<String, dynamic>? metadata;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Museum({
    required this.id,
    required this.museumName,
    this.museumNameAr,
    this.description,
    this.descriptionAr,
    this.coverImage,
    required this.location,
    this.latitude,
    this.longitude,
    this.artworkTypes = const [],
    this.artistIds = const [],
    this.status = 'published',
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  // Localized helpers
  String localizedName({required String languageCode}) {
    final ar = (museumNameAr ?? '').trim();
    final en = museumName.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : ar;
  }

  String? localizedDescription({required String languageCode}) {
    final ar = (descriptionAr ?? '').trim();
    final en = (description ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  // Mapping
  factory Museum.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toUtc();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
      if (v is String && v.trim().isNotEmpty) return DateTime.parse(v).toUtc();
      return null;
    }

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.trim().isNotEmpty) return double.tryParse(v);
      return null;
    }

    List<String> _stringList(dynamic v) {
      if (v == null) return const <String>[];
      if (v is List) {
        return v
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList(growable: false);
      }
      return const <String>[];
    }

    return Museum(
      id: map['id'] as String,
      museumName: map['museum_name'] as String,
      museumNameAr: map['museum_name_ar'] as String?,
      description: map['description'] as String?,
      descriptionAr: map['description_ar'] as String?,
      coverImage: map['cover_image'] as String?,
      location: map['location'] as String,
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      artworkTypes: _stringList(map['artwork_types']),
      artistIds: _stringList(map['artist_ids']),
      status: (map['status'] ?? 'published') as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'museum_name': museumName,
      'museum_name_ar': museumNameAr,
      'description': description,
      'description_ar': descriptionAr,
      'cover_image': coverImage,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'artwork_types': artworkTypes,
      'artist_ids': artistIds,
      'status': status,
      'metadata': metadata,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }
}
