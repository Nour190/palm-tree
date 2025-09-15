import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class CategoryChipsAdaptive extends StatelessWidget {
  const CategoryChipsAdaptive({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.centerWhenFits = false,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// When chips fit without scrolling, optionally center them.
  final bool centerWhenFits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: LayoutBuilder(
        builder: (context, c) {
          final maxWidth = c.maxWidth;

          // Breakpoints via width (consistent with your DeviceType).
          final isMobile = maxWidth < 600;
          final isTablet = maxWidth >= 600 && maxWidth < 900;

          // Size tuning per platform
          final chipHeight = isMobile ? 46.h : (isTablet ? 44.h : 42.h);
          final horizontalPadding = isMobile ? 18.h : (isTablet ? 18.h : 16.h);
          final spacing = isMobile ? 16.h : (isTablet ? 16.h : 16.h);
          final borderWidth = 1.0;

          // Choose text style
          final selectedStyle = TextStyleHelper.instance.title16MediumInter
              .copyWith(color: AppColor.white);
          final unselectedStyle = TextStyleHelper.instance.title16RegularInter
              .copyWith(color: AppColor.gray900);

          // Estimate total width to decide whether to scroll
          final totalWidth = _estimateTotalWidth(
            context: context,
            items: items,
            selectedIndex: selectedIndex,
            selectedStyle: selectedStyle,
            unselectedStyle: unselectedStyle,
            chipHeight: chipHeight,
            hp: horizontalPadding,
            spacing: spacing,
            borderWidth: borderWidth,
          );

          final fits = totalWidth <= maxWidth;

          return Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: fits
                ? _NonScrollRow(
                    items: items,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                    chipHeight: chipHeight,
                    horizontalPadding: horizontalPadding,
                    spacing: spacing,
                    borderWidth: borderWidth,
                    selectedStyle: selectedStyle,
                    unselectedStyle: unselectedStyle,
                    center: centerWhenFits,
                  )
                : _ScrollRow(
                    items: items,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                    chipHeight: chipHeight,
                    horizontalPadding: horizontalPadding,
                    spacing: spacing,
                    borderWidth: borderWidth,
                    selectedStyle: selectedStyle,
                    unselectedStyle: unselectedStyle,
                  ),
          );
        },
      ),
    );
  }

  double _estimateTotalWidth({
    required BuildContext context,
    required List<String> items,
    required int selectedIndex,
    required TextStyle selectedStyle,
    required TextStyle unselectedStyle,
    required double chipHeight,
    required double hp,
    required double spacing,
    required double borderWidth,
  }) {
    var sum = 0.0;
    final borderInset = borderWidth; // 1px border on unselected
    for (int i = 0; i < items.length; i++) {
      final style = (i == selectedIndex) ? selectedStyle : unselectedStyle;
      final textWidth = _textWidth(context, items[i], style);
      final pillWidth =
          textWidth + (hp * 2) + ((i == selectedIndex) ? 0 : borderInset * 2);
      sum += pillWidth;
      if (i < items.length - 1) sum += spacing;
    }
    return sum;
  }

  double _textWidth(BuildContext context, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.size.width;
  }
}

/* ---------------------------
   Non-scroll row (fits)
   --------------------------- */
class _NonScrollRow extends StatelessWidget {
  const _NonScrollRow({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.chipHeight,
    required this.horizontalPadding,
    required this.spacing,
    required this.borderWidth,
    required this.selectedStyle,
    required this.unselectedStyle,
    this.center = false,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double chipHeight;
  final double horizontalPadding;
  final double spacing;
  final double borderWidth;
  final TextStyle selectedStyle;
  final TextStyle unselectedStyle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: Row(
        mainAxisAlignment: center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: List.generate(items.length * 2 - 1, (idx) {
          if (idx.isOdd) return SizedBox(width: spacing);
          final i = idx ~/ 2;
          return _ChipPill(
            label: items[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
            height: chipHeight,
            horizontalPadding: horizontalPadding,
            borderWidth: borderWidth,
            selectedStyle: selectedStyle,
            unselectedStyle: unselectedStyle,
          );
        }),
      ),
    );
  }
}

/* ---------------------------
   Scroll row (overflow)
   --------------------------- */
class _ScrollRow extends StatelessWidget {
  const _ScrollRow({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.chipHeight,
    required this.horizontalPadding,
    required this.spacing,
    required this.borderWidth,
    required this.selectedStyle,
    required this.unselectedStyle,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double chipHeight;
  final double horizontalPadding;
  final double spacing;
  final double borderWidth;
  final TextStyle selectedStyle;
  final TextStyle unselectedStyle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: Row(
        children: List.generate(items.length * 2 - 1, (idx) {
          if (idx.isOdd) return SizedBox(width: spacing);
          final i = idx ~/ 2;
          return _ChipPill(
            label: items[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
            height: chipHeight,
            horizontalPadding: horizontalPadding,
            borderWidth: borderWidth,
            selectedStyle: selectedStyle,
            unselectedStyle: unselectedStyle,
          );
        }),
      ),
    );
  }
}

/* ---------------------------
   Chip atom
   --------------------------- */
class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.height,
    required this.horizontalPadding,
    required this.borderWidth,
    required this.selectedStyle,
    required this.unselectedStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final double horizontalPadding;
  final double borderWidth;
  final TextStyle selectedStyle;
  final TextStyle unselectedStyle;

  @override
  Widget build(BuildContext context) {
    final style = selected ? selectedStyle : unselectedStyle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.h),
        splashColor: selected
            ? AppColor.white.withOpacity(0.08)
            : AppColor.gray900.withOpacity(0.06),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColor.gray900 : AppColor.white,
            borderRadius: BorderRadius.circular(24.h),
            border: selected
                ? null
                : Border.all(color: AppColor.blueGray100, width: borderWidth),
          ),
          child: Text(
            label,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }
}
