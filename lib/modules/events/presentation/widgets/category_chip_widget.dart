import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/events/data/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryChipWidget extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryChipWidget({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isSelected = category.isSelected ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.h : 20.h,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF12130F) : AppColor.white,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: AppColor.blueGray100, width: 1.h),
        ),
        child: Text(
          category.title ?? '',
          style: TextStyleHelper.instance.title16Inter.copyWith(
            color: isSelected ? Color(0xFFFFFFFF) : AppColor.gray900,
          ),
        ),
      ),
    );
  }
}
