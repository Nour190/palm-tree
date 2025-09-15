class LocationModel {
  final String id;
  final String? country;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final DateTime? createdAt;

  LocationModel({
    required this.id,
    this.country,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      country: json['country'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
