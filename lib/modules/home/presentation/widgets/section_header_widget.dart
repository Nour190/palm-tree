import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  /// Whether to show the "See More" button
  final bool showSeeMore;

  /// Callback when "See More" is tapped
  final VoidCallback? onSeeMore;

  /// Customizable text for the button
  final String seeMoreButtonText;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 5),
    this.showSeeMore = false,
    this.onSeeMore,
    this.seeMoreButtonText = "See More",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                color: AppColor.gray900,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showSeeMore && onSeeMore != null) ...[
            const SizedBox(width: 12),
            _buildSeeMoreButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSeeMore,
          borderRadius: BorderRadius.circular(24),
          splashColor: AppColor.primaryColor.withOpacity(0.1),
          highlightColor: AppColor.primaryColor.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor,
                  AppColor.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
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
