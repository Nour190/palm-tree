class InfoModel {
  final String id;
  final String mainTitle;
  final String subTitle;
  final List<String> images;

  final String? about;
  final List<String> aboutImages;

  final String? vision;
  final List<String> visionImages;

  final String? mission;
  final List<String> missionImages;

  final DateTime? createdAt; // UTC
  final DateTime? updatedAt; // UTC

  const InfoModel({
    required this.id,
    required this.mainTitle,
    required this.subTitle,
    this.images = const [],
    this.about,
    this.aboutImages = const [],
    this.vision,
    this.visionImages = const [],
    this.mission,
    this.missionImages = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory InfoModel.fromMap(Map<String, dynamic> map) => InfoModel(
    id: map['id'] as String,
    mainTitle: map['main_title'] as String,
    subTitle: map['sub_title'] as String,
    images: List<String>.from(map['images'] ?? const []),
    about: map['about'] as String?,
    aboutImages: List<String>.from(map['about_images'] ?? const []),
    vision: map['vision'] as String?,
    visionImages: List<String>.from(map['vision_images'] ?? const []),
    mission: map['mission'] as String?,
    missionImages: List<String>.from(map['mission_images'] ?? const []),
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at']).toUtc()
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at']).toUtc()
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'main_title': mainTitle,
    'sub_title': subTitle,
    'images': images,
    'about': about,
    'about_images': aboutImages,
    'vision': vision,
    'vision_images': visionImages,
    'mission': mission,
    'mission_images': missionImages,
  };

  InfoModel copyWith({
    String? id,
    String? mainTitle,
    String? subTitle,
    List<String>? images,
    String? about,
    List<String>? aboutImages,
    String? vision,
    List<String>? visionImages,
    String? mission,
    List<String>? missionImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InfoModel(
      id: id ?? this.id,
      mainTitle: mainTitle ?? this.mainTitle,
      subTitle: subTitle ?? this.subTitle,
      images: images ?? this.images,
      about: about ?? this.about,
      aboutImages: aboutImages ?? this.aboutImages,
      vision: vision ?? this.vision,
      visionImages: visionImages ?? this.visionImages,
      mission: mission ?? this.mission,
      missionImages: missionImages ?? this.missionImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
