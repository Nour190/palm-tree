// lib/modules/home/data/models/artist_model.dart

class Artist {
  final String id;

  // EN
  final String name;
  final String? profileImage;
  final int? age;
  final String? about;
  final String? country;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;

  // AR
  final String? nameAr;
  final String? aboutAr;
  final String? countryAr;
  final String? cityAr;
  final String? addressAr;
  final String? platformAr;

  // Media / presence
  final List<String> gallery;
  final bool isLive;
  final String? platform; // instagram | website | soundcloud | ...
  final String? url;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Artist({
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
    this.nameAr,
    this.aboutAr,
    this.countryAr,
    this.cityAr,
    this.addressAr,
    this.platformAr,
    this.gallery = const [],
    this.isLive = false,
    this.platform,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------- Localized helpers ----------------
  String localizedName({required String languageCode}) {
    final ar = (nameAr ?? '').trim();
    final en = name.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : ar;
  }

  String? localizedAbout({required String languageCode}) {
    final ar = (aboutAr ?? '').trim();
    final en = (about ?? '').trim();
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

  String? localizedCity({required String languageCode}) {
    final ar = (cityAr ?? '').trim();
    final en = (city ?? '').trim();
    if (languageCode == 'ar' && ar.isNotEmpty) return ar;
    if (en.isNotEmpty) return en;
    return ar.isNotEmpty ? ar : null;
  }

  String? localizedAddress({required String languageCode}) {
    final ar = (addressAr ?? '').trim();
    final en = (address ?? '').trim();
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

  // ---------------- Mapping ----------------
  factory Artist.fromMap(Map<String, dynamic> map) {
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

    return Artist(
      id: map['id'] as String,
      name: map['name'] as String,
      profileImage: map['profile_image'] as String?,
      age: map['age'] as int?,
      about: map['about'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      address: map['address'] as String?,
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),

      nameAr: map['name_ar'] as String?,
      aboutAr: map['about_ar'] as String?,
      countryAr: map['country_ar'] as String?,
      cityAr: map['city_ar'] as String?,
      addressAr: map['address_ar'] as String?,
      platformAr: map['platform_ar'] as String?,

      gallery: _stringList(map['gallery']),
      isLive: (map['is_live'] ?? false) as bool,
      platform: map['platform'] as String?,
      url: map['url'] as String?,

      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // EN
      'name': name,
      'profile_image': profileImage,
      'age': age,
      'about': about,
      'country': country,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      // AR
      'name_ar': nameAr,
      'about_ar': aboutAr,
      'country_ar': countryAr,
      'city_ar': cityAr,
      'address_ar': addressAr,
      'platform_ar': platformAr,
      // Media / presence
      'gallery': gallery,
      'is_live': isLive,
      'platform': platform,
      'url': url,
    };
  }
}
