import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resourses/style_manager.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String imageAsset;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.imageAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.sH,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:AppColor.white,
          side: const BorderSide(color:AppColor.backgroundGray ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, width: 20.sW, height: 20.sH),
            SizedBox(width: 12.sW),
            Text(
              text,
              style: TextStyleHelper.instance.title16BoldInter,
            ),
          ],
        ),
      ),
    );
  }
}
