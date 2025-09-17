import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class ChatTabWidget extends StatelessWidget {
  const ChatTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chatItems = [
      {
        'title': 'Clay Whispers',
        'message': 'Pottery pieces that carry the warmth of craftsman...',
        'time': '08:00 AM',
        'image': AppAssetsManager.imgRectangle1,
      },
      {
        'title': 'Whisper of the Horizon',
        'message': 'A canvas capturing the gradient of the sky at sunset...',
        'time': '09:00 AM',
        'image': AppAssetsManager.imgRectangle2,
      },
      {
        'title': 'Shadows of the Old City',
        'message': 'A scene of a historic town painted with thick oil...',
        'time': '10:00 AM',
        'image': AppAssetsManager.imgRectangle4,
      },
      {
        'title': 'Dance of Light',
        'message': 'A painting that portrays sunlight shimmering across...',
        'time': '11:00 AM',
        'image': AppAssetsManager.imgEllipse13,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.sH),
      child: Column(
        children: chatItems.map((item) => _buildChatItem(item)).toList(),
      ),
    );
  }

  Widget _buildChatItem(Map<String, String> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.sH),
      padding: EdgeInsets.symmetric(vertical: 16.sH, horizontal: 16.sW),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.gray400.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Chat Avatar
          Container(
            width: 60.sW,
            height: 60.sW,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                item['image']!,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12.sW),

          // Chat Details
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

                SizedBox(height: 4.sH),

                Text(
                  item['message']!,
                  style: TextStyleHelper.instance.body12LightInter.copyWith(
                    color: AppColor.gray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time
          Text(
            item['time']!,
            style: TextStyleHelper.instance.body12LightInter.copyWith(
              color: AppColor.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
