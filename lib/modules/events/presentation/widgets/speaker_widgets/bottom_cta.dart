import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import '../../../../../core/resourses/style_manager.dart';

class BottomCta extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDesktop;

  const BottomCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                  //  fontSize: isDesktop ? 24 : 20,
                    color: AppColor.gray900,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.title14BlackRegularInter.copyWith(
                    // fontSize: isDesktop ? 16 : 14,
                    color: AppColor.gray400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width:  10.sW),
          Expanded(
            flex: isDesktop? 1:3,
            child: Container(
              height: isDesktop ? 80.sH : 140.sH,
              decoration: BoxDecoration(
                color: AppColor.blackGrey,
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColor.white,
                  size: isDesktop ? 40.sSp : 45.sSp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
