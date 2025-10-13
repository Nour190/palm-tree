class Speaker {
  final String id;
  final String name;
  final String? nameAr;
  final String? profileImage;
  final int? age;
  final String? bio;
  final String? bioAr;
  final String? expertise;
  final String? expertiseAr;
  final String? organization;
  final String? organizationAr;

  // Topic
  final String? topicName;
  final String? topicDescription;
  final String? topicNameAr;
  final String? topicDescriptionAr;

  // Schedule (store UTC; keep timezone for display)
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;

  // Location
  final String? addressLine;
  final String? addressLineAr;
  final String? district;
  final String? districtAr;
  final String? city;
  final String? cityAr;
  final String? country;
  final String? countryAr;
  final double? latitude;
  final double? longitude;

  // Media
  final List<String> gallery;

  // Live
  final bool isLive;
  final String? platform;
  final String? platformAr;
  final String? url;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Speaker({
    required this.id,
    required this.name,
    this.nameAr,
    this.profileImage,
    this.age,
    this.bio,
    this.bioAr,
    this.expertise,
    this.expertiseAr,
    this.organization,
    this.organizationAr,
    this.topicName,
    this.topicDescription,
    this.topicNameAr,
    this.topicDescriptionAr,
    required this.startAt,
    required this.endAt,
    this.timezone = 'UTC',
    this.addressLine,
    this.addressLineAr,
    this.district,
    this.districtAr,
    this.city,
    this.cityAr,
    this.country,
    this.countryAr,
    this.latitude,
    this.longitude,
    this.gallery = const [],
    this.isLive = false,
    this.platform,
    this.platformAr,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory Speaker.fromMap(Map<String, dynamic> map) {
    return Speaker(
      id: map['id'] as String,
      name: map['name'] as String,
      nameAr: map['name_ar'] as String?,
      profileImage: map['profile_image'] as String?,
      age: map['age'] as int?,
      bio: map['bio'] as String?,
      bioAr: map['bio_ar'] as String?,
      expertise: map['expertise'] as String?,
      expertiseAr: map['expertise_ar'] as String?,
      organization: map['organization'] as String?,
      organizationAr: map['organization_ar'] as String?,
      topicName: map['topic_name'] as String?,
      topicDescription: map['topic_description'] as String?,
      topicNameAr: map['topic_name_ar'] as String?,
      topicDescriptionAr: map['topic_description_ar'] as String?,
      startAt: DateTime.parse(map['start_at']).toUtc(),
      endAt: DateTime.parse(map['end_at']).toUtc(),
      timezone: (map['timezone'] ?? 'UTC') as String,
      addressLine: map['address_line'] as String?,
      addressLineAr: map['address_line_ar'] as String?,
      district: map['district'] as String?,
      districtAr: map['district_ar'] as String?,
      city: map['city'] as String?,
      cityAr: map['city_ar'] as String?,
      country: map['country'] as String?,
      countryAr: map['country_ar'] as String?,
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      gallery: List<String>.from(map['gallery'] ?? const []),
      isLive: (map['is_live'] ?? false) as bool,
      platform: map['platform'] as String?,
      platformAr: map['platform_ar'] as String?,
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
      'name_ar': nameAr,
      'profile_image': profileImage,
      'age': age,
      'bio': bio,
      'bio_ar': bioAr,
      'expertise': expertise,
      'expertise_ar': expertiseAr,
      'organization': organization,
      'organization_ar': organizationAr,
      'topic_name': topicName,
      'topic_description': topicDescription,
      'topic_name_ar': topicNameAr,
      'topic_description_ar': topicDescriptionAr,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'timezone': timezone,
      'address_line': addressLine,
      'address_line_ar': addressLineAr,
      'district': district,
      'district_ar': districtAr,
      'city': city,
      'city_ar': cityAr,
      'country': country,
      'country_ar': countryAr,
      'latitude': latitude,
      'longitude': longitude,
      'gallery': gallery,
      'is_live': isLive,
      'platform': platform,
      'platform_ar': platformAr,
      'url': url,
    };
  }

  String localizedName({required String languageCode}) {
    final ar = (nameAr ?? '').trim();
    final en = name.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : ar;
  }

  String? localizedBio({required String languageCode}) {
    final ar = (bioAr ?? '').trim();
    final en = (bio ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedExpertise({required String languageCode}) {
    final ar = (expertiseAr ?? '').trim();
    final en = (expertise ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedOrganization({required String languageCode}) {
    final ar = (organizationAr ?? '').trim();
    final en = (organization ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedTopicName({required String languageCode}) {
    final ar = (topicNameAr ?? '').trim();
    final en = (topicName ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedTopicDescription({required String languageCode}) {
    final ar = (topicDescriptionAr ?? '').trim();
    final en = (topicDescription ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedAddressLine({required String languageCode}) {
    final ar = (addressLineAr ?? '').trim();
    final en = (addressLine ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedDistrict({required String languageCode}) {
    final ar = (districtAr ?? '').trim();
    final en = (district ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedCity({required String languageCode}) {
    final ar = (cityAr ?? '').trim();
    final en = (city ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedCountry({required String languageCode}) {
    final ar = (countryAr ?? '').trim();
    final en = (country ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedPlatform({required String languageCode}) {
    final ar = (platformAr ?? '').trim();
    final en = (platform ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }
}
