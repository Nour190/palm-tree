import 'package:baseqat/modules/artist_details/presentation/widgets/lightbox_dialog.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/network_image_smart.dart';
import 'package:flutter/material.dart';

class ArtistGalleryGrid extends StatelessWidget {
  final List<String> gallery;
  const ArtistGalleryGrid({super.key, required this.gallery});

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  @override
  Widget build(BuildContext context) {
    if (gallery.isEmpty) return const SizedBox.shrink();
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    final crossAxisCount = isMobile
        ? 2
        : isTablet
        ? 3
        : 4;
    final spacing = isMobile ? 12.0 : 16.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5F5F5), Color(0xFFFAFAFA)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gallery',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF7F7F7), Color(0xFFFCFCFC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  '${gallery.length} ${gallery.length == 1 ? 'photo' : 'photos'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gallery.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () => showLightbox(
                  context: context,
                  gallery: gallery,
                  initialIndex: i,
                ),
                child: Hero(
                  tag: 'gallery_$i',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      child: NetworkImageSmart(
                        path: gallery[i],
                        fit: BoxFit.cover,
                        radius: BorderRadius.circular(isMobile ? 12 : 16),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
