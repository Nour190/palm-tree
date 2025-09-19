import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:flutter/material.dart';

import '../../../../../core/resourses/style_manager.dart';

class SpeakersHeader extends StatelessWidget {
  final String title;
  final bool isDesktop;

  const SpeakersHeader({
    super.key,
    required this.title,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleHelper.instance.headline24BoldInter.copyWith(
        //fontSize: isDesktop ? 36 : 28,
        color: AppColor.gray900,
        height: 1.2,
      ),
    );
  }
}
