// speakers_header.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';

class SpeakersHeader extends StatelessWidget {
  final String title;
  final bool isDesktop;
  const SpeakersHeader({super.key, required this.title, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: (isDesktop
              ? TextStyleHelper.instance.headline20BoldInter
              : TextStyleHelper.instance.title16BoldInter)
          .copyWith(color: AppColor.black),
    );
  }
}
