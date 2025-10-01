
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/services/locale_service.dart';
import 'package:baseqat/core/components/custom_widgets/ithra_menu_screen.dart';
 import 'dart:ui' as ui;

class TopBar extends StatelessWidget {
  TopBar({
    super.key,
    String? logoPath,
    this.brand ,
    required this.items,
    this.selectedIndex = 0,
    this.onItemTap,
    this.onLoginTap,
    this.showScanButton = true,
    this.onScanTap,
    this.maxTabletItems = 4,
    this.compactOnMobile = true,
  }) : logoPath = logoPath ?? AppAssetsManager.imgLogo;

  final String logoPath;
  final String? brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;
  final int maxTabletItems;
  final bool compactOnMobile;

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => IthraMenuScreen(
          logoPath: logoPath,
          brand: brand?? "navigation.home".tr(),
          items: items,
          selectedIndex: selectedIndex,
          onItemTap: onItemTap,
          onLoginTap: onLoginTap,
          onScanTap: onScanTap,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = LocaleService.isRTL(context.locale);

    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Container(
        height: 80.sH,
        padding: EdgeInsets.symmetric( vertical: 16.sSp),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColor.gray200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Row(
              children: [
                Container(
                  width: 40.sW,
                  height: 40.sH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sH),
                  ),
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12.sSp),
                Text(
                  brand?? "navigation.home".tr(),
                  style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (showScanButton && onScanTap != null)
              GestureDetector(
                onTap: onScanTap,
                child: Container(
                  width: 48.sW,
                  height: 48.sH,
                  margin: EdgeInsets.only(right: 12.sSp),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    //borderRadius: BorderRadius.circular(8.sH),
                    shape: BoxShape.circle,

                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _openMenu(context),
              child: Container(
                width: 48.sW,
                height: 48.sH,
                decoration:  BoxDecoration(
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                  color: AppColor.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu,
                  color: AppColor.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class _CurvedBackgroundPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey.withOpacity(0.1)
//       ..style = PaintingStyle.fill;
//
//     final path = Path();
//
//     path.moveTo(0, size.height * 0.3);
//     path.quadraticBezierTo(
//       size.width * 0.3, size.height * 0.1,
//       size.width * 0.7, size.height * 0.2,
//     );
//     path.quadraticBezierTo(
//       size.width * 0.9, size.height * 0.25,
//       size.width, size.height * 0.1,
//     );
//     path.lineTo(size.width, 0);
//     path.lineTo(0, 0);
//     path.close();
//
//     canvas.drawPath(path, paint);
//
//     final path2 = Path();
//     path2.moveTo(size.width, size.height * 0.7);
//     path2.quadraticBezierTo(
//       size.width * 0.7, size.height * 0.9,
//       size.width * 0.3, size.height * 0.8,
//     );
//     path2.quadraticBezierTo(
//       size.width * 0.1, size.height * 0.75,
//       0, size.height * 0.9,
//     );
//     path2.lineTo(0, size.height);
//     path2.lineTo(size.width, size.height);
//     path2.close();
//
//     canvas.drawPath(path2, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
