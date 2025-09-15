// lib/data/models/artwork_model.dart
class ArtworkModel {
  final String id;
  final String title;
  final String? imageUrl;
  final List<String> gallery;
  final String? about;
  final String? vision;
  final String? style;
  final String? medium;
  final String? materials;
  final double? estimatedValue;
  final String? dimensions;
  final bool isForSale;
  final double? price;
  final String? locationId;
  final String? artistId;
  final String? chatId;
  final DateTime? createdAt;

  ArtworkModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.gallery = const [],
    this.about,
    this.vision,
    this.style,
    this.medium,
    this.materials,
    this.estimatedValue,
    this.dimensions,
    this.isForSale = false,
    this.price,
    this.locationId,
    this.artistId,
    this.chatId,
    this.createdAt,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      gallery: List<String>.from(json['gallery'] ?? []),
      about: json['about'] as String?,
      vision: json['vision'] as String?,
      style: json['style'] as String?,
      medium: json['medium'] as String?,
      materials: json['materials'] as String?,
      estimatedValue: (json['estimated_value'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      isForSale: json['is_for_sale'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble(),
      locationId: json['location_id'] as String?,
      artistId: json['artist_id'] as String?,
      chatId: json['chat_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'gallery': gallery,
      'about': about,
      'vision': vision,
      'style': style,
      'medium': medium,
      'materials': materials,
      'estimated_value': estimatedValue,
      'dimensions': dimensions,
      'is_for_sale': isForSale,
      'price': price,
      'location_id': locationId,
      'artist_id': artistId,
      'chat_id': chatId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
