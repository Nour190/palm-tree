class GalleryItem {
  final String imageUrl;
  final String artworkId;
  final String artworkName;
  final String? artworkType;
  final List<String> fullGallery;
  final String? artistId;
  final String? artistName;
  final String? artistProfileImage;

  const GalleryItem({
    required this.imageUrl,
    this.artworkId = '',
    this.artworkName = '',
    this.artworkType,
    this.fullGallery = const [],
    this.artistId,
    this.artistName,
    this.artistProfileImage,
  });
}
