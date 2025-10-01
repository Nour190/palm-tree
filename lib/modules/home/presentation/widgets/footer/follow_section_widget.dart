import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'social_icon_widget.dart';

class FollowSectionWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubscribe;

  const FollowSectionWidget({
    super.key,
    required this.controller,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;
    final spacing = isMobile ? 16.sH : 20.sH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'footer.follow_us'.tr(),
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
        SizedBox(height: 8.sH),
        _buildSocialIcons(context),
        SizedBox(height: spacing),
        Text(
          'footer.subscribe_updates'.tr(),
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
        SizedBox(height: 8.sH),
        _buildSubscribeForm(context),
      ],
    );
  }

  Widget _buildSocialIcons(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Wrap(
      spacing: isMobile ? 12.sW : 16.sW,
      children: const [
        SocialIconWidget(icon: Icons.facebook, label: 'Facebook'),
        SocialIconWidget(icon: Icons.business_center, label: 'LinkedIn'),
        SocialIconWidget(icon: Icons.alternate_email, label: 'X (Twitter)'),
      ],
    );
  }

  Widget _buildSubscribeForm(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final textFieldHeight = isMobile ? 44.sH : 52.sH;
    final borderRadius = isMobile ? 8.sH : 12.sH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: textFieldHeight,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: isMobile
                ? styles.body14RegularInter.copyWith(
                    color: AppColor.gray900,
                    fontSize: Responsive.responsiveFontSize(context, 12),
                  )
                : styles.title16RegularInter.copyWith(
                    color: AppColor.gray900,
                    fontSize: Responsive.responsiveFontSize(context, 14),
                  ),
            decoration: InputDecoration(
              hintText: 'footer.enter_email'.tr(),
              filled: true,
              fillColor: AppColor.whiteCustom,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12.sW : 16.sW,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              hintStyle: isMobile
                  ? styles.body14RegularInter.copyWith(
                      color: AppColor.gray400,
                      fontSize: Responsive.responsiveFontSize(context, 12),
                    )
                  : styles.title16RegularInter.copyWith(
                      color: AppColor.gray400,
                      fontSize: Responsive.responsiveFontSize(context, 14),
                    ),
            ),
            onSubmitted: (_) => onSubscribe(),
          ),
        ),
        SizedBox(height: 12.sH),
        _buildSubscribeButton(context),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final buttonHeight = isMobile ? 44.sH : 52.sH;
    final borderRadius = isMobile ? 8.sH : 12.sH;
    final horizontalPadding = isMobile ? 16.sW : 24.sW;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColor.whiteCustom,
        foregroundColor: AppColor.gray900,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8.sH,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(0, buttonHeight),
      ),
      onPressed: onSubscribe,
      child: Text(
        'footer.subscribe'.tr(),
        style: isMobile
            ? styles.title14MediumInter.copyWith(
                fontSize: Responsive.responsiveFontSize(context, 12),
              )
            : styles.title16MediumInter.copyWith(
                fontSize: Responsive.responsiveFontSize(context, 14),
              ),
      ),
    );
  }
}
