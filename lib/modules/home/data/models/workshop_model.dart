// lib/models/workshop.dart
import 'helpers.dart';

class Workshop {
  final String id;

  // FK
  final String artistId;

  // EN
  final String name;
  final String? description;
  final String? location;
  final String? country;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;

  // AR
  final String? nameAr;
  final String? descriptionAr;
  final String? locationAr;
  final String? countryAr;
  final String? cityAr;
  final String? addressAr;

  // Time
  final DateTime startAt;
  final DateTime endAt;

  // Capacity & audience
  final int seatsTotal;
  final int seatsAvailable;
  final String? ageGroup;
  final String? ageGroupAr;

  // Format & pricing
  final bool isOnline;
  final String? meetingUrl;
  final double? priceAmount;
  final String? priceCurrency;
  final String? registrationUrl;

  // Media
  final String? coverImage;
  final List<String> gallery;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional denormalized (if you SELECT with JOINs)
  final String? artistName;
  final String? artistNameAr;
  final String? artistProfileImage;

  const Workshop({
    required this.id,
    required this.artistId,
    required this.name,
    required this.startAt,
    required this.endAt,
    this.description,
    this.location,
    this.country,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.nameAr,
    this.descriptionAr,
    this.locationAr,
    this.countryAr,
    this.cityAr,
    this.addressAr,
    this.seatsTotal = 0,
    this.seatsAvailable = 0,
    this.ageGroup,
    this.ageGroupAr,
    this.isOnline = false,
    this.meetingUrl,
    this.priceAmount,
    this.priceCurrency,
    this.registrationUrl,
    this.coverImage,
    this.gallery = const [],
    this.createdAt,
    this.updatedAt,
    this.artistName,
    this.artistNameAr,
    this.artistProfileImage,
  });

  factory Workshop.fromMap(Map<String, dynamic> map) {
    return Workshop(
      id: map['id'] as String,
      artistId: map['artist_id'] as String,

      // EN
      name: map['name'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      country: map['country'] as String?,
      city: map['city'] as String?,
      address: map['address'] as String?,
      latitude: toDoubleOrNull(map['latitude']),
      longitude: toDoubleOrNull(map['longitude']),

      // AR
      nameAr: map['name_ar'] as String?,
      descriptionAr: map['description_ar'] as String?,
      locationAr: map['location_ar'] as String?,
      countryAr: map['country_ar'] as String?,
      cityAr: map['city_ar'] as String?,
      addressAr: map['address_ar'] as String?,

      // Time
      startAt: parseDate(map['start_at'])!,
      endAt: parseDate(map['end_at'])!,

      // Capacity
      seatsTotal: (map['seats_total'] ?? 0) as int,
      seatsAvailable: (map['seats_available'] ?? 0) as int,
      ageGroup: map['age_group'] as String?,
      ageGroupAr: map['age_group_ar'] as String?,

      // Format / pricing
      isOnline: (map['is_online'] ?? false) as bool,
      meetingUrl: map['meeting_url'] as String?,
      priceAmount: toDoubleOrNull(map['price_amount']),
      priceCurrency: map['price_currency'] as String?,
      registrationUrl: map['registration_url'] as String?,

      // Media
      coverImage: map['cover_image'] as String?,
      gallery: asStringList(map['gallery']),

      // Timestamps
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),

      // Optional denormalized
      artistName: map['artist_name'] as String?,
      artistNameAr: map['artist_name_ar'] as String?,
      artistProfileImage: map['artist_profile_image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artist_id': artistId,

      // EN
      'name': name,
      'description': description,
      'location': location,
      'country': country,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,

      // AR
      'name_ar': nameAr,
      'description_ar': descriptionAr,
      'location_ar': locationAr,
      'country_ar': countryAr,
      'city_ar': cityAr,
      'address_ar': addressAr,

      // Time
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),

      // Capacity
      'seats_total': seatsTotal,
      'seats_available': seatsAvailable,
      'age_group': ageGroup,
      'age_group_ar': ageGroupAr,

      // Format / pricing
      'is_online': isOnline,
      'meeting_url': meetingUrl,
      'price_amount': priceAmount,
      'price_currency': priceCurrency,
      'registration_url': registrationUrl,

      // Media
      'cover_image': coverImage,
      'gallery': gallery,
    };
  }
}
