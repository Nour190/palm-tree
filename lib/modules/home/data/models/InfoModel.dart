// lib/modules/home/data/models/info_model.dart

class InfoModel {
  final String id;

  // EN
  final String mainTitle;
  final String subTitle;
  final List<String> bannerImages;
  final List<String> galleryImages;
  final String? about;
  final List<String> aboutImages;
  final String? vision;
  final List<String> visionImages;
  final String? mission;
  final List<String> missionImages;

  // AR
  final String? mainTitleAr;
  final String? subTitleAr;
  final String? aboutAr;
  final String? visionAr;
  final String? missionAr;

  // Timestamps (UTC)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InfoModel({
    required this.id,
    required this.mainTitle,
    required this.subTitle,
    this.bannerImages = const [],
    this.galleryImages=const [],
    this.about,
    this.aboutImages = const [],
    this.vision,
    this.visionImages = const [],
    this.mission,
    this.missionImages = const [],
    this.mainTitleAr,
    this.subTitleAr,
    this.aboutAr,
    this.visionAr,
    this.missionAr,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------- Localized helpers ----------------
  String localizedMainTitle({required bool isRTL}) {
    final ar = (mainTitleAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : mainTitle;
  }

  String localizedSubTitle({required bool isRTL}) {
    final ar = (subTitleAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : subTitle;
  }

  String? localizedAbout({required bool isRTL}) {
    final ar = (aboutAr ?? '').trim();
    final en = (about ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  String? localizedVision({required bool isRTL}) {
    final ar = (visionAr ?? '').trim();
    final en = (vision ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  String? localizedMission({required bool isRTL}) {
    final ar = (missionAr ?? '').trim();
    final en = (mission ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  // ---------------- Mapping ----------------
  factory InfoModel.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toUtc();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
      if (v is String && v.trim().isNotEmpty) return DateTime.parse(v).toUtc();
      return null;
    }

    List<String> _stringList(dynamic v) {
      if (v == null) return const <String>[];
      if (v is List) {
        return v.where((e) => e != null).map((e) => e.toString()).toList(growable: false);
      }
      return const <String>[];
    }

    return InfoModel(
      id: map['id'] as String,
      // EN
      mainTitle: map['main_title'] as String,
      subTitle: map['sub_title'] as String,
      bannerImages: _stringList(map['banner_images']),
      galleryImages: _stringList(map['gallery']),
      about: map['about'] as String?,
      aboutImages: _stringList(map['about_images']),
      vision: map['vision'] as String?,
      visionImages: _stringList(map['vision_images']),
      mission: map['mission'] as String?,
      missionImages: _stringList(map['mission_images']),
      // AR
      mainTitleAr: map['main_title_ar'] as String?,
      subTitleAr: map['sub_title_ar'] as String?,
      aboutAr: map['about_ar'] as String?,
      visionAr: map['vision_ar'] as String?,
      missionAr: map['mission_ar'] as String?,
      // Timestamps
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        // EN
        'main_title': mainTitle,
        'sub_title': subTitle,
        'banner_images': bannerImages,
        'gallery':galleryImages,
        'about': about,
        'about_images': aboutImages,
        'vision': vision,
        'vision_images': visionImages,
        'mission': mission,
        'mission_images': missionImages,
        // AR
        'main_title_ar': mainTitleAr,
        'sub_title_ar': subTitleAr,
        'about_ar': aboutAr,
        'vision_ar': visionAr,
        'mission_ar': missionAr,
        // timestamps generally server-managed on write
      };

  Map<String, dynamic> toJson() => toMap();
  factory InfoModel.fromJson(Map<String, dynamic> json) => InfoModel.fromMap(json);

  InfoModel copyWith({
    String? id,
    String? mainTitle,
    String? subTitle,
    List<String>? bannerImages,
    List<String>? galleryImages,
    String? about,
    List<String>? aboutImages,
    String? vision,
    List<String>? visionImages,
    String? mission,
    List<String>? missionImages,
    String? mainTitleAr,
    String? subTitleAr,
    String? aboutAr,
    String? visionAr,
    String? missionAr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InfoModel(
      id: id ?? this.id,
      mainTitle: mainTitle ?? this.mainTitle,
      subTitle: subTitle ?? this.subTitle,
      bannerImages: bannerImages ?? this.bannerImages,
      galleryImages: galleryImages ?? this.galleryImages,
      about: about ?? this.about,
      aboutImages: aboutImages ?? this.aboutImages,
      vision: vision ?? this.vision,
      visionImages: visionImages ?? this.visionImages,
      mission: mission ?? this.mission,
      missionImages: missionImages ?? this.missionImages,
      mainTitleAr: mainTitleAr ?? this.mainTitleAr,
      subTitleAr: subTitleAr ?? this.subTitleAr,
      aboutAr: aboutAr ?? this.aboutAr,
      visionAr: visionAr ?? this.visionAr,
      missionAr: missionAr ?? this.missionAr,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
