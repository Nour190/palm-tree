// ======================= Artist =======================
class Artist {
  final String id;
  final String name;
  final String? profileImage;
  final int? age;
  final String? about;

  // Location
  final String? country;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;

  // Media
  final List<String> gallery;

  // Live audio
  final bool isLive;
  final String? platform; // e.g. "spotify", "soundcloud", "app_stream"
  final String? url; // audio stream link

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Artist({
    required this.id,
    required this.name,
    this.profileImage,
    this.age,
    this.about,
    this.country,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.gallery = const [],
    this.isLive = false,
    this.platform,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'] as String,
      name: map['name'] as String,
      profileImage: map['profile_image'] as String?,
      age: map['age'] as int?,
      about: map['about'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      address: map['address'] as String?,
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
      'about': about,
      'country': country,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'gallery': gallery,
      'is_live': isLive,
      'platform': platform,
      'url': url,
    };
  }
}
