class ReviewModel {
  final String name;
  final String textEn;
  final String textAr;
  final double rating;
  final String gender;
  final String avatarUrl;

  ReviewModel({
    required this.name,
    required this.textEn,
    required this.textAr,
    required this.rating,
    required this.gender,
    required this.avatarUrl,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      name: map['reviewer_name'] as String,
      textEn: map['text_en'] as String,
      textAr: map['text_ar'] as String,
      rating: (map['rating'] as num).toDouble(),
      gender: map['gender'] as String,
      avatarUrl: map['avatar_url'] as String,
    );
  }
}
