import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';

class BottomCta extends StatelessWidget {
  const BottomCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final spacingMedium = ProgramsLayout.spacingMedium(context);
    final height = ProgramsLayout.size(context, 200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(
              ProgramsLayout.radius20(context),
            ),
          ),
          child: Center(
            child: Image(
              image: AssetImage(
                'assets/images/sun_image.png',
              ),
              height: ProgramsLayout.size(context, 140),
              width: ProgramsLayout.size(context, 140),
            ),
          ),
        ),
        SizedBox(height: spacingLarge),
        Text(
          title,
          style: ProgramsTypography.headingLarge(
            context,
          ).copyWith(color: AppColor.black, height: 1.2),
        ),
        SizedBox(height: spacingMedium),
        Text(
          subtitle,
          style: ProgramsTypography.bodySecondary(
            context,
          ).copyWith(color: AppColor.gray600, height: 1.45),
        ),
      ],
    );
  }
}
