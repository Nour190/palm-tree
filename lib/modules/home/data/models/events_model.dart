// ======================= Event (artwork_ids lives here) =======================
class Event {
  final String id;
  final String title;
  final String? description;

  // Schedule
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;

  // Location
  final String? venueName;
  final String? addressLine;
  final String? district;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Media
  final String? coverImage;
  final List<String> gallery;

  // UX/Admin
  final bool isPublic;
  final int? capacity;
  final String? ticketUrl;

  // Artworks: zero/one/many IDs (uuid[])
  final List<String> artworkIds;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    required this.endAt,
    this.timezone = 'UTC',
    this.venueName,
    this.addressLine,
    this.district,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.coverImage,
    this.gallery = const [],
    this.isPublic = true,
    this.capacity,
    this.ticketUrl,
    this.artworkIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startAt: DateTime.parse(map['start_at']).toUtc(),
      endAt: DateTime.parse(map['end_at']).toUtc(),
      timezone: (map['timezone'] ?? 'UTC') as String,
      venueName: map['venue_name'] as String?,
      addressLine: map['address_line'] as String?,
      district: map['district'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      coverImage: map['cover_image'] as String?,
      gallery: List<String>.from(map['gallery'] ?? const []),
      isPublic: (map['is_public'] ?? true) as bool,
      capacity: map['capacity'] as int?,
      ticketUrl: map['ticket_url'] as String?,
      artworkIds: List<String>.from(map['artwork_ids'] ?? const []),
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
      'title': title,
      'description': description,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'timezone': timezone,
      'venue_name': venueName,
      'address_line': addressLine,
      'district': district,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'cover_image': coverImage,
      'gallery': gallery,
      'is_public': isPublic,
      'capacity': capacity,
      'ticket_url': ticketUrl,
      'artwork_ids': artworkIds,
    };
  }
}
