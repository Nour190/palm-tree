// lib/modules/events/presentation/utils/events_ui_utils.dart
import 'package:flutter/material.dart';

import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/components/custom_widgets/custom_search_view.dart';
import 'package:baseqat/modules/events/presentation/widgets/category_chip_widget.dart';
import 'package:baseqat/modules/arts_works/presentation/widgets/category_model.dart';

/// Search field used at the top of the screen.
class EventsSearchField extends StatelessWidget {
  const EventsSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'What do you want to see today ?',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return CustomSearchView(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      prefixIcon: AppAssetsManager.imgSearch,
      fillColor: AppColor.white,
      borderColor: AppColor.gray400,
    );
  }
}

/// Horizontal, scrollable row of category chips.
/// Optionally prefixes each chip with a 2‑digit index (01, 02, ...)
class EventsCategoryChips extends StatelessWidget {
  const EventsCategoryChips({
    super.key,
    required this.categories,
    required this.onTap,
    this.spacing = 16,
    this.showIndex = false,
  });

  final List<CategoryModel> categories;
  final ValueChanged<int> onTap;
  final double spacing;
  final bool showIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: spacing.h,
        children: List.generate(categories.length, (index) {
          final c = categories[index];
          final display = showIndex
              ? CategoryModel(
                  title: '${(index + 1).toString().padLeft(2, '0')} ${c.title}',
                  isSelected: c.isSelected,
                )
              : c;
          return CategoryChipWidget(
            category: display,
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }
}

/// Generic "Coming soon" placeholder.
class ComingSoon extends StatelessWidget {
  const ComingSoon(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title coming soon',
        style: TextStyleHelper.instance.title16BoldInter,
      ),
    );
  }
}
