import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class ProfileTabNavigationWidget extends StatelessWidget {
  const ProfileTabNavigationWidget({
    super.key,
    required this.selectedTabIndex,
    required this.onTabTap,
    this.tabs = const ['Likes', 'Chat', 'Notification', 'Settings'],
  });

  final int selectedTabIndex;
  final Function(int) onTabTap;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.sH,
      padding: EdgeInsets.symmetric(horizontal: 1.sW),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.gray400, width: 1.sW),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabTap(index),
              child: Container(
                height: 56.sH,
                margin: EdgeInsets.symmetric(horizontal: 4.sW),
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border(
                    bottom: BorderSide(
                      color: AppColor.black,
                      width: 2.sW,
                    ),
                  )
                      : null,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sW,
                      vertical: 8.sH,
                    ),
                    child: Text(
                      tabs[index],
                      style: isSelected
                          ? TextStyleHelper.instance.title16BoldInter.copyWith(
                        color: AppColor.black,
                        fontSize: 16.sSp,
                      )
                          : TextStyleHelper.instance.title16RegularInter.copyWith(
                        color: AppColor.gray400,
                        fontSize: 16.sSp,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
