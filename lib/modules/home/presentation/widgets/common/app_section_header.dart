// lib/modules/home/presentation/widgets/common/app_section_header.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double maxTextWidthFraction;
  final bool emphasize; // for the “hero” header scale-up

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.maxTextWidthFraction = 0.9,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * maxTextWidthFraction;
    final styles = TextStyleHelper.instance;

    final titleStyle = emphasize
        ? styles.display48BoldInter.copyWith(
            color: AppColor.gray900,
            height: 1.2,
          )
        : styles.headline24BoldInter.copyWith(color: AppColor.gray900);

    final subtitleStyle = styles.title16LightInter.copyWith(
      color: AppColor.gray900,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: maxWidth,
            child: Text(subtitle!, style: subtitleStyle),
          ),
        ],
      ],
    );
  }
}
