class GalleryItem {
  final String imageUrl;
  final String artistId;
  final String artistName;
  final String? artistProfileImage;

  const GalleryItem({
    required this.imageUrl,
    required this.artistId,
    required this.artistName,
    this.artistProfileImage,
  });
}
