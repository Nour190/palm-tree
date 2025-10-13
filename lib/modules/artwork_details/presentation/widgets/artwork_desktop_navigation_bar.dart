import 'package:baseqat/modules/programs/data/models/category_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/responsive/size_ext.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';

class ArtworkDesktopNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTap;
  final List<CategoryModel> categories;
  final String? title;
  final String? subtitle;
  final bool showBranding;
  final VoidCallback? onLogoTap;

  const ArtworkDesktopNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.categories,
    this.title,
    this.subtitle,
    this.showBranding = true,
    this.onLogoTap,
  });

  @override
  State<ArtworkDesktopNavigationBar> createState() =>
      _ArtworkDesktopNavigationBarState();
}

class _ArtworkDesktopNavigationBarState
    extends State<ArtworkDesktopNavigationBar> {

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width < 1024;

    return Container(

      width: isTablet ? 240.sW : 280.sW,
      padding: EdgeInsets.all(24.sW),
      decoration: BoxDecoration(
        color: AppColor.backgroundWhite,
        border: Border(
          right: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 10,
        //     offset: const Offset(2, 0),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              SizedBox(width: 12.sW),
              Text(
                'Art work',
                style: TextStyleHelper.instance.headline20BoldInter,
              ),
            ],
          ),
          SizedBox(height: 32.sH),

          Text(
            'DISCOVER',
            style: TextStyleHelper.instance.caption12RegularInter
                .copyWith(
              color: AppColor.gray500,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(height: 16.sH),
          Expanded(child: _buildNavigationItems()),
          _buildVersion(),
        ],
      ),
    );
  }


  Widget _buildNavigationItems() {
    return Expanded(
      child:ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = index == widget.selectedIndex;

          return Container(
            margin: EdgeInsets.only(bottom: 4.sH),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onItemTap(index),
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
      // Padding(
      //   padding: EdgeInsets.all(12.sW),
      //   child: ListView.separated(
      //     itemCount: widget.categories.length,
      //     separatorBuilder: (_, __) => SizedBox(height: 6.sH),
      //     itemBuilder: (context, index) {
      //       final category = widget.categories[index];
      //       final isSelected = index == widget.selectedIndex;
      //       final isHovered = _hoveredIndex == index;
      //
      //       return MouseRegion(
      //         onEnter: (_) => setState(() => _hoveredIndex = index),
      //         onExit: (_) => setState(() => _hoveredIndex = null),
      //         child: Material(
      //           color: Colors.transparent,
      //           child: InkWell(
      //             onTap: () => widget.onItemTap(index),
      //             borderRadius: BorderRadius.circular(12.sW),
      //             child: Container(
      //               padding: EdgeInsets.symmetric(
      //                 horizontal: 14.sW,
      //                 vertical: 14.sH,
      //               ),
      //               decoration: BoxDecoration(
      //                 color: _getBackgroundColor(isSelected, isHovered),
      //                 borderRadius: BorderRadius.circular(12.sW),
      //                 border: _getBorder(isSelected, isHovered),
      //                 boxShadow: _getBoxShadow(isSelected, isHovered),
      //               ),
      //               child:
      //               // Row(
      //               //   children: [
      //               //     // Left accent when selected
      //               //     // Container(
      //               //     //   width: 4.sW,
      //               //     //   height: 24.sH,
      //               //     //   margin: EdgeInsets.only(right: 10.sW),
      //               //     //   decoration: BoxDecoration(
      //               //     //     color: isSelected
      //               //     //         ? AppColor.primaryColor
      //               //     //         : Colors.transparent,
      //               //     //     borderRadius: BorderRadius.circular(2.sW),
      //               //     //   ),
      //               //     // ),
      //               //
      //               //     // Icon
      //               //     Container(
      //               //       padding: EdgeInsets.all(6.sW),
      //               //       decoration: BoxDecoration(
      //               //         color: _getIconBackgroundColor(
      //               //           isSelected,
      //               //           isHovered,
      //               //         ),
      //               //         borderRadius: BorderRadius.circular(8.sW),
      //               //       ),
      //               //       child: Icon(
      //               //         _getIconForCategory(category.title ?? ''),
      //               //         size: 18.sW,
      //               //         color: _getIconColor(isSelected, isHovered),
      //               //       ),
      //               //     ),
      //               //     SizedBox(width: 12.sW),
      //               //
      //               //     // Title
      //               //     Expanded(
      //               //       child: Text(
      //               //         category.title ?? '',
      //               //         style: TextStyleHelper
      //               //             .instance
      //               //             .title14BlackRegularInter
      //               //             .copyWith(
      //               //               color: _getTextColor(isSelected, isHovered),
      //               //               fontWeight: isSelected
      //               //                   ? FontWeight.w600
      //               //                   : FontWeight.w500,
      //               //             ),
      //               //         maxLines: 1,
      //               //         overflow: TextOverflow.ellipsis,
      //               //       ),
      //               //     ),
      //               //
      //               //     // Optional notification dot
      //               //     if (_hasNotification(category.title ?? ''))
      //               //       Container(
      //               //         width: 8.sW,
      //               //         height: 8.sH,
      //               //         margin: EdgeInsets.only(right: 8.sW),
      //               //         decoration: const BoxDecoration(
      //               //           color: Colors.red,
      //               //           shape: BoxShape.circle,
      //               //         ),
      //               //       ),
      //               //
      //               //     // Selected chevron
      //               //     if (isSelected)
      //               //       Icon(
      //               //         Icons.chevron_right,
      //               //         size: 16.sW,
      //               //         color: AppColor.primaryColor,
      //               //       ),
      //               //   ],
      //               // ),
      //             ),
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }

  Widget _buildVersion() {
    return Container(
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'Version 1.0.0',
        style: TextStyleHelper.instance.caption12RegularInter.copyWith(
          color: AppColor.gray400,
        ),
      ),
    );
  }








  IconData _getIconForCategory(String title) {
    switch (title.toLowerCase()) {
      case 'about':
        return Icons.palette_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'chat ai':
        return Icons.smart_toy_outlined;
      case 'gallery':
        return Icons.photo_library_outlined;
      case 'feedback':
        return Icons.reviews_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'events':
        return Icons.event_outlined;
      case 'artists':
        return Icons.brush_outlined;
      case 'profile':
        return Icons.person_outline;
      case 'settings':
        return Icons.settings_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
