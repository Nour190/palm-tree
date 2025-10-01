import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

class ReviewerNameWidget extends StatelessWidget {
  const ReviewerNameWidget({
    super.key,
    required this.name,
    this.alignLeft = false,
  });

  final String name;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Text(
      name,
      textAlign: alignLeft ? TextAlign.left : TextAlign.center,
      style: styles.title18BoldInter.copyWith(
        color: AppColor.whiteCustom,
        height: 1.15,
      ),
    );
  }
}
