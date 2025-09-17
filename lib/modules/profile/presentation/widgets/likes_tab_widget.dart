import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class LikesTabWidget extends StatelessWidget {
  const LikesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final likedItems = [
      {
        'title': 'Clay Whispers',
        'description': 'Pottery pieces that carry the warmth of craftsmanship and the touch of nature, each creation telling a story of patience, tradition, and artistry. From the shaping of raw clay to the final glaze, these pieces embody the harmony between human hands and the earth, bringing soulful beauty and a sense of calm to any home or space',
        'image': AppAssetsManager.imgRectangle1,
      },
      {
        'title': 'Fasel Asaad',
        'description': 'Pottery pieces that carry the warmth of craftsmanship and the touch of nature, each creation telling a story of patience, tradition, and artistry. From the shaping of raw clay to the final glaze, these pieces embody the harmony between human hands and the earth, bringing soulful beauty and a sense of calm to any home or space',
        'image': AppAssetsManager.imgEllipse13,
      },
      {
        'title': 'Roots Entrance',
        'description': 'This room is dedicated to showcasing artworks created with oil paints, highlighting the rich details and layered depth that distinguish this medium. Designed to offer visitors a calm and focused visual experience, the space features balanced lighting that enhances the beauty of colors and brush textures. Here, visitors can explore the diversity of artistic',
        'image': AppAssetsManager.imgRectangle2,
      },
      {
        'title': 'The aromry show',
        'description': 'Kiaf SEOUL 2025 takes place from September 3rd to September 7th at COEX Hall, Seoul. Browse a selection of fresh works by Hye-Eun Kang, Son Seock, JUNSEOK KANG at the fair on Artsy and collect from our partner galleries including Gallery Dasun, Mark Hachem Gallery, PIGMENT Gallery, and more.',
        'image': AppAssetsManager.imgRectangle4,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: likedItems.map((item) => _buildLikedItem(item)).toList(),
      ),
    );
  }

  Widget _buildLikedItem(Map<String, String> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sH),
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.sW),
        border: Border.all(color: AppColor.gray400.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Container(
            width: 80.sW,
            height: 80.sW,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sW),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sW),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12.sW),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: TextStyleHelper.instance.title16BoldInter.copyWith(
                    color: AppColor.black,
                  ),
                ),

                SizedBox(height: 8.sH),

                Text(
                  item['description']!,
                  style: TextStyleHelper.instance.body12LightInter.copyWith(
                    color: AppColor.gray700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Heart Icon
          Container(
            width: 40.sW,
            height: 40.sW,
            decoration: BoxDecoration(
              color: AppColor.gray400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: AppColor.white,
              size: 20.sSp,
            ),
          ),
        ],
      ),
    );
  }
}
