import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import '../../data/models/gallery_item.dart';

class GalleryGrid extends StatelessWidget {
  final List<GalleryItem> items;
  final void Function(GalleryItem item)? onTap;

  const GalleryGrid({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No gallery yet'));
    }
    return GridView.builder(
      padding: EdgeInsets.all(12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // tune by deviceType if you want
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.h,
        childAspectRatio: 4 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return GestureDetector(
          onTap: () => onTap?.call(it),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.h),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  it.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                  loadingBuilder: (c, child, p) {
                    if (p == null) return child;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Colors.grey[200]),
                        Center(
                          child: SizedBox(
                            width: 18.h,
                            height: 18.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  left: 8.h,
                  bottom: 8.h,
                  right: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.h,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Text(
                      it.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
