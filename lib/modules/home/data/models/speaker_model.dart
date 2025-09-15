class Speaker {
  final String id;
  final String name;
  final String? profileImage;
  final int? age;
  final String? bio;
  final String? expertise;
  final String? organization;

  // Topic
  final String? topicName;
  final String? topicDescription;

  // Schedule (store UTC; keep timezone for display)
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;

  // Location
  final String? addressLine;
  final String? district;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Media
  final List<String> gallery;

  // Live
  final bool isLive;
  final String? platform;
  final String? url;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Speaker({
    required this.id,
    required this.name,
    this.profileImage,
    this.age,
    this.bio,
    this.expertise,
    this.organization,
    this.topicName,
    this.topicDescription,
    required this.startAt,
    required this.endAt,
    this.timezone = 'UTC',
    this.addressLine,
    this.district,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.gallery = const [],
    this.isLive = false,
    this.platform,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory Speaker.fromMap(Map<String, dynamic> map) {
    return Speaker(
      id: map['id'] as String,
      name: map['name'] as String,
      profileImage: map['profile_image'] as String?,
      age: map['age'] as int?,
      bio: map['bio'] as String?,
      expertise: map['expertise'] as String?,
      organization: map['organization'] as String?,
      topicName: map['topic_name'] as String?,
      topicDescription: map['topic_description'] as String?,
      startAt: DateTime.parse(map['start_at']).toUtc(),
      endAt: DateTime.parse(map['end_at']).toUtc(),
      timezone: (map['timezone'] ?? 'UTC') as String,
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
      gallery: List<String>.from(map['gallery'] ?? const []),
      isLive: (map['is_live'] ?? false) as bool,
      platform: map['platform'] as String?,
      url: map['url'] as String?,
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
      'profile_image': profileImage,
      'age': age,
      'bio': bio,
      'expertise': expertise,
      'organization': organization,
      'topic_name': topicName,
      'topic_description': topicDescription,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'timezone': timezone,
      'address_line': addressLine,
      'district': district,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'gallery': gallery,
      'is_live': isLive,
      'platform': platform,
      'url': url,
    };
  }
}
