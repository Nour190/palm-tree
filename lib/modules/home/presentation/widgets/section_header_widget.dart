import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final bool showSeeMore;
  final VoidCallback? onSeeMore;
  final String seeMoreButtonText;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.padding,
    this.showSeeMore = false,
    this.onSeeMore,
    this.seeMoreButtonText = 'See More',
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 32.sW
              : isTablet
              ? 24.sW
              : 16.sW,
        );

    return Padding(
      padding: resolvedPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                color: AppColor.gray900,
                height: 1.28,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showSeeMore && onSeeMore != null) ...[
            SizedBox(width: 12.sW),
            Semantics(
              button: true,
              label: 'See more $title',
              child: _buildSeeMoreButton(deviceType),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton(DeviceType deviceType) {
    final bool isDesktop = deviceType == DeviceType.desktop;
    final bool isTablet = deviceType == DeviceType.tablet;

    final horizontalPad = isDesktop
        ? 24.sW
        : isTablet
        ? 22.sW
        : 18.sW;
    final verticalPad = isDesktop
        ? 12.sH
        : isTablet
        ? 11.sH
        : 10.sH;

    final double radius = isDesktop ? 26.sH : 22.sH;
    final double iconSize = isDesktop ? 18.sSp : 16.sSp;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSeeMore,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColor.primaryColor.withOpacity(0.1),
          highlightColor: AppColor.primaryColor.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: verticalPad,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor,
                  AppColor.primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.25),
                  blurRadius: 12.sH,
                  offset: Offset(0, 4.sH),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  seeMoreButtonText,
                  style: TextStyleHelper.instance.title14MediumInter.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.sW),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: iconSize,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
