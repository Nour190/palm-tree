// bottom_cta.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';

class BottomCta extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDesktop;

  const BottomCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: isDesktop ? 220 : 180,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
          ),
          child: Center(child: Icon(icon, size: isDesktop ? 64 : 56, color: Colors.white)),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        Text(
          title,
          style: (isDesktop
                  ? TextStyleHelper.instance.headline20BoldInter
                  : TextStyleHelper.instance.title16BoldInter)
              .copyWith(color: AppColor.black, height: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyleHelper.instance.body12MediumInter
              .copyWith(color: AppColor.gray600, height: 1.45),
        ),
      ],
    );
  }
}
