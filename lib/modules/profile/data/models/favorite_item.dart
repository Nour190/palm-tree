class FavoriteItem {
  final String favUid;          // favorites.fav_uid (UUID)
  final String userId;          // favorites.user_id
  final String entityKind;      // 'artist' | 'artwork' | 'speaker'
  final String entityId;        // the entity uuid
  final String? title;          // optional snapshot title
  final String? description;    // optional snapshot description
  final String? imageUrl;       // optional snapshot image
  final DateTime createdAt;     // row created_at

  FavoriteItem({
    required this.favUid,
    required this.userId,
    required this.entityKind,
    required this.entityId,
    required this.createdAt,
    this.title,
    this.description,
    this.imageUrl,
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> m) {
    return FavoriteItem(
      favUid: m['fav_uid'] as String,
      userId: m['user_id'] as String,
      entityKind: m['entity_kind'] as String,
      entityId: m['entity_id'] as String,
      title: m['title'] as String?,
      description: m['description'] as String?,
      imageUrl: m['image_url'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}
