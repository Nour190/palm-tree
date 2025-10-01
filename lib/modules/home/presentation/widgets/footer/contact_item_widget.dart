import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ContactItemWidget extends StatelessWidget {
  final String title, value;

  const ContactItemWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'footer.$title'.tr().toLowerCase(),
          style: isMobile
              ? styles.title16MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                )
              : styles.headline20MediumInter.copyWith(
                  color: AppColor.gray400,
                  fontSize: Responsive.responsiveFontSize(context, 18),
                ),
        ),
        SizedBox(height: 4.sH),
        SelectableText(
          value,
          style: isMobile
              ? styles.body14RegularInter.copyWith(
                  color: AppColor.whiteCustom,
                  fontSize: Responsive.responsiveFontSize(context, 12),
                )
              : styles.title16RegularInter.copyWith(
                  color: AppColor.whiteCustom,
                  fontSize: Responsive.responsiveFontSize(context, 14),
                ),
        ),
      ],
    );
  }
}
