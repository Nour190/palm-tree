import 'package:flutter/material.dart';
import '../../../../core/responsive/size_ext.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';
import '../../../../core/resourses/assets_manager.dart';
import '../../data/models/category_model.dart' ;

class DesktopNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;
  final List<CategoryModel> categories;

  const DesktopNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.sW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 12.sW),
              Text(
                'Events',
                style: TextStyleHelper.instance.headline20BoldInter,
              ),
            ],
          ),
          
          SizedBox(height: 32.sH),
          
          Text(
            'EXPLORE',
            style: TextStyleHelper.instance.caption12RegularInter
                .copyWith(
                  color: AppColor.gray500,
                  letterSpacing: 1.2,
                ),
          ),
          
          SizedBox(height: 16.sH),
          
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = index == selectedIndex;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 4.sH),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onItemTap(index),
                      borderRadius: BorderRadius.circular(8.sW),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.sW,
                          vertical: 12.sH,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColor.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.sW),
                          border: isSelected
                              ? Border.all(
                                  color: AppColor.primaryColor.withOpacity(0.2),
                                  width: 1.sW,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForCategory(category.title!),
                              size: 20.sW,
                              color: isSelected 
                                  ? AppColor.primaryColor
                                  : AppColor.gray600,
                            ),
                            SizedBox(width: 12.sW),
                            Expanded(
                              child: Text(
                                category.title!,
                                style: TextStyleHelper.instance.title16RegularInter
                                    .copyWith(
                                      color: isSelected 
                                          ? AppColor.primaryColor
                                          : AppColor.gray700,
                                      fontWeight: isSelected 
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(16.sW),
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius: BorderRadius.circular(12.sW),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.sW,
                  backgroundColor: AppColor.primaryColor,
                  child: Icon(
                    Icons.person,
                    size: 16.sW,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyleHelper.instance.caption12RegularInter
                            .copyWith(color: AppColor.gray600),
                      ),
                      Text(
                        'Explorer',
                        style: TextStyleHelper.instance.body14RegularInter
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String title) {
    switch (title.toLowerCase()) {
      case 'art works':
        return Icons.palette;
      case 'artist':
        return Icons.person_outline;
      case 'speakers':
        return Icons.mic;
      case 'gallery':
        return Icons.photo_library;
      case 'virtual tour':
        return Icons.view_in_ar;
      default:
        return Icons.category;
    }
  }
}
