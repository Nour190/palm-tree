import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    this.userName = 'Mostafa Adel',
    this.userImage,
  });

  final String userName;
  final String? userImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Avatar
        Container(
          width: 100.sW,
          height: 100.sW,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.gray400, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              userImage ?? AppAssetsManager.imgEllipse13,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        SizedBox(height: 14.sH),
        
        // Profile Name
        Text(
          userName,
          style: TextStyleHelper.instance.headline24BoldInter.copyWith(
            color: AppColor.black,
          ),
        ),
      ],
    );
  }
}
