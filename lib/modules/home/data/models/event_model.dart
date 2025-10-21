class Event {
  final String id;

  // Basic info
  final String name;
  final String? nameAr;
  final String? overview;
  final String? overviewAr;

  // Media
  final String? circleAvatar;
  final String? coverImage;
  final String? overviewImages;

  // Location
  final double? latitude;
  final double? longitude;

  // Schedule
  final DateTime? eventDate;

  // Relations
  final List<String> artistIds; // Array of artist IDs
  final List<String> artworkIds; // Array of artwork IDs for artist gallery

  // Status
  final String status; // draft, planned, published, cancelled

  // Metadata
  final Map<String, dynamic>? metadata;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.name,
    this.nameAr,
    this.overview,
    this.overviewAr,
    this.circleAvatar,
    this.coverImage,
    this.overviewImages ="",
    this.latitude,
    this.longitude,
    this.eventDate,
    this.artistIds = const [],
    this.artworkIds = const [],
    this.status = 'published',
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  // Localized helpers
  String localizedName({required String languageCode}) {
    final ar = (nameAr ?? '').trim();
    final en = name.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : ar;
  }

  String? localizedOverview({required String languageCode}) {
    final ar = (overviewAr ?? '').trim();
    final en = (overview ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  // Mapping
  factory Event.fromMap(Map<String, dynamic> map) {
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

    return Event(
      id: map['id'] as String,
      name: map['name'] as String,
      nameAr: map['name_ar'] as String?,
      overview: map['overview'] as String?,
      overviewAr: map['overview_ar'] as String?,
      circleAvatar: map['circle_avatar'] as String?,
      coverImage: map['cover_image'] as String?,
      overviewImages: map['overview_images'],
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      eventDate: _parseDate(map['event_date']),
      artistIds: _stringList(map['artist_ids']),
      artworkIds: _stringList(map['artwork_ids']),
      status: (map['status'] ?? 'published') as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'overview': overview,
      'overview_ar': overviewAr,
      'circle_avatar': circleAvatar,
      'cover_image': coverImage,
      'overview_images': overviewImages,
      'latitude': latitude,
      'longitude': longitude,
      'event_date': eventDate?.toUtc().toIso8601String(),
      'artist_ids': artistIds,
      'artwork_ids': artworkIds,
      'status': status,
      'metadata': metadata,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }
}
