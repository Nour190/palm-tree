class Event {
  final String id;
  final String title;
  final String? description;

  // Location
  final String? venueName;
  final String? addressLine;
  final String? district;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Schedule
  final DateTime? startAt;
  final DateTime? endAt;
  final String timezone;

  // Media & taxonomy
  final String? bannerImageUrl;
  final String? avatarImageUrl;
  final String? category;
  final List<String> tags;
  final List<String> artistIds;

  // Flags
  final bool isFeatured;

  const Event({
    required this.id,
    required this.title,
    this.description,
    this.venueName,
    this.addressLine,
    this.district,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.startAt,
    this.endAt,
    this.timezone = 'UTC',
    this.bannerImageUrl,
    this.avatarImageUrl,
    this.category,
    this.tags = const [],
    this.artistIds = const [],
    this.isFeatured = false,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString())?.toUtc();
    double? _dbl(dynamic v) => v == null ? null : (v as num?)?.toDouble();
    List<String> _list(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const [];

    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      venueName: map['venue_name'] as String?,
      addressLine: map['address_line'] as String?,
      district: map['district'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: _dbl(map['latitude']),
      longitude: _dbl(map['longitude']),
      startAt: _dt(map['start_at']),
      endAt: _dt(map['end_at']),
      timezone: (map['timezone'] ?? 'UTC') as String,
      bannerImageUrl: map['banner_image_url'] as String?,
      avatarImageUrl: map['avatar_image_url'] as String?,
      category: map['category'] as String?,
      tags: _list(map['tags']),
      artistIds: _list(map['artist_ids']),
      isFeatured: (map['is_featured'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'venue_name': venueName,
      'address_line': addressLine,
      'district': district,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'start_at': startAt?.toUtc().toIso8601String(),
      'end_at': endAt?.toUtc().toIso8601String(),
      'timezone': timezone,
      'banner_image_url': bannerImageUrl,
      'avatar_image_url': avatarImageUrl,
      'category': category,
      'tags': tags,
      'artist_ids': artistIds,
      'is_featured': isFeatured,
    };
  }
}
