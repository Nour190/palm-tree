// import 'dart:ui' as ui;
// import 'dart:math' as math;
// import 'package:baseqat/core/responsive/size_ext.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:baseqat/core/resourses/color_manager.dart';
// import 'package:baseqat/core/responsive/size_utils.dart';
// import 'package:baseqat/core/resourses/style_manager.dart';
// import 'package:baseqat/core/resourses/assets_manager.dart';
// import 'package:baseqat/core/services/locale_service.dart';
// import 'package:baseqat/modules/auth/logic/auth_gate_cubit/auth_cubit.dart';
// import 'package:baseqat/modules/auth/logic/auth_gate_cubit/auth_state.dart';
//
// class TopBar extends StatefulWidget {
//   TopBar({
//     super.key,
//     String? logoPath,
//     this.brand = 'ithra',
//     required this.items,
//     this.selectedIndex = 0,
//     this.onItemTap,
//     this.onLoginTap,
//     this.showScanButton = true,
//     this.onScanTap,
//     this.maxTabletItems = 4,
//     this.compactOnMobile = true,
//   }) : logoPath = logoPath ?? AppAssetsManager.imgLogo;
//
//   final String logoPath;
//   final String brand;
//   final List<String> items;
//   final int selectedIndex;
//   final ValueChanged<int>? onItemTap;
//   final VoidCallback? onLoginTap;
//   final bool showScanButton;
//   final VoidCallback? onScanTap;
//   final int maxTabletItems;
//   final bool compactOnMobile;
//
//   @override
//   State<TopBar> createState() => _TopBarState();
// }
//
// class _TopBarState extends State<TopBar> with TickerProviderStateMixin {
//   bool _isDropdownOpen = false;
//   bool _isLanguageExpanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _fadeAnimation;
//
//   final List<Map<String, dynamic>> _languages = [
//     {'name': 'Arabic', 'code': 'ar', 'locale': const Locale('ar', 'SA'), 'flag': '🇸🇦'},
//     {'name': 'English', 'code': 'en', 'locale': const Locale('en', 'US'), 'flag': '🇬🇧'},
//     {'name': 'Germany', 'code': 'de', 'locale': const Locale('de', 'DE'), 'flag': '🇩🇪'},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<double>(
//       begin: -1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 0.5,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleDropdown() {
//     setState(() {
//       _isDropdownOpen = !_isDropdownOpen;
//     });
//     if (_isDropdownOpen) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }
//
//   void _closeDropdown() {
//     if (_isDropdownOpen) {
//       setState(() {
//         _isDropdownOpen = false;
//         _isLanguageExpanded = false;
//       });
//       _animationController.reverse();
//     }
//   }
//
//   Future<void> _changeLanguage(Map<String, dynamic> language) async {
//     await LocaleService.changeLocale(context, language['locale']);
//     _closeDropdown();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isRTL = LocaleService.isRTL(context.locale);
//
//     return Directionality(
//       textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
//       child: Stack(
//         children: [
//           _IthraHeader(
//             logoPath: widget.logoPath,
//             brand: widget.brand,
//             onMenuTap: _toggleDropdown,
//             onScanTap: widget.onScanTap,
//             isMenuOpen: _isDropdownOpen,
//             isRTL: isRTL,
//           ),
//           if (_isDropdownOpen)
//             Positioned.fill(
//               child: _IthraFullScreenDropdown(
//                 logoPath: widget.logoPath,
//                 brand: widget.brand,
//                 items: widget.items,
//                 selectedIndex: widget.selectedIndex,
//                 languages: _languages,
//                 isLanguageExpanded: _isLanguageExpanded,
//                 onClose: _closeDropdown,
//                 onItemTap: (index) {
//                   widget.onItemTap?.call(index);
//                   _closeDropdown();
//                 },
//                 onLoginTap: () {
//                   widget.onLoginTap?.call();
//                   _closeDropdown();
//                 },
//                 onLanguageToggle: () {
//                   setState(() {
//                     _isLanguageExpanded = !_isLanguageExpanded;
//                   });
//                 },
//                 onLanguageSelect: _changeLanguage,
//                 isRTL: isRTL,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// class _IthraHeader extends StatelessWidget {
//   const _IthraHeader({
//     required this.logoPath,
//     required this.brand,
//     required this.onMenuTap,
//     required this.onScanTap,
//     required this.isMenuOpen,
//     required this.isRTL,
//   });
//
//   final String logoPath;
//   final String brand;
//   final VoidCallback onMenuTap;
//   final VoidCallback? onScanTap;
//   final bool isMenuOpen;
//   final bool isRTL;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80.sH,
//       padding: EdgeInsets.symmetric( vertical: 16.sSp),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColor.gray200, width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40.sW,
//                 height: 40.sH,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.sH),
//                 ),
//                 child: Image.asset(
//                   logoPath,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               SizedBox(width: 12.sSp),
//               Text(
//                 brand,
//                 style: TextStyleHelper.instance.headline24BoldInter.copyWith(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           if (onScanTap != null)
//             GestureDetector(
//               onTap: onScanTap,
//               child: Container(
//                 width: 48.sW,
//                 height: 48.sH,
//                 margin: EdgeInsets.only(right: 12.sSp),
//                 decoration: BoxDecoration(
//                   color:AppColor.primaryColor,
//                  // borderRadius: BorderRadius.circular(8.sH),
//                   shape:  BoxShape.circle
//                 ),
//                 child: const Icon(
//                   Icons.qr_code_scanner,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//           GestureDetector(
//             onTap: onMenuTap,
//             child: Container(
//               width: 48.sW,
//               height: 48.sH,
//               decoration: BoxDecoration(
//                 color: isMenuOpen ? Colors.transparent : AppColor.white,
//                 border: Border.all(color: AppColor.primaryColor, width: 2) ,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isMenuOpen ? Icons.close : Icons.menu,
//                 color: AppColor.primaryColor,
//                 size: 24,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _IthraFullScreenDropdown extends StatelessWidget {
//   const _IthraFullScreenDropdown({
//     required this.logoPath,
//     required this.brand,
//     required this.items,
//     required this.selectedIndex,
//     required this.languages,
//     required this.isLanguageExpanded,
//     required this.onClose,
//     required this.onItemTap,
//     required this.onLoginTap,
//     required this.onLanguageToggle,
//     required this.onLanguageSelect,
//     required this.isRTL,
//   });
//
//   final String logoPath;
//   final String brand;
//   final List<String> items;
//   final int selectedIndex;
//   final List<Map<String, dynamic>> languages;
//   final bool isLanguageExpanded;
//   final VoidCallback onClose;
//   final ValueChanged<int> onItemTap;
//   final VoidCallback onLoginTap;
//   final VoidCallback onLanguageToggle;
//   final ValueChanged<Map<String, dynamic>> onLanguageSelect;
//   final bool isRTL;
//
//   @override
//   Widget build(BuildContext context) {
//     final currentLang = languages.firstWhere(
//           (lang) => lang['code'] == context.locale.languageCode,
//       orElse: () => languages[0],
//     );
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         image: DecorationImage(
//           image: AssetImage(AppAssetsManager.background), // You can replace with actual background pattern
//           fit: BoxFit.contain,
//          // opacity: 0.05,
//         ),
//       ),
//       child: Stack(
//         children: [
//           // CustomPaint(
//           //   size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
//           //   painter: _CurvedBackgroundPainter(),
//           // ),
//
//           SafeArea(
//             child: Column(
//               children: [
//                 Container(
//                   height: 80.sH,
//                   // padding: EdgeInsets.symmetric(vertical: 1.sSp),
//                   child: Row(
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 40.sW,
//                             height: 40.sH,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8.sH),
//                             ),
//                             child: Image.asset(
//                               logoPath,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(width: 12.sSp),
//                           Text(
//                             brand,
//                             style: TextStyleHelper.instance.headline24BoldInter.copyWith(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Row(
//                         children: [
//                           Container(
//                             width: 48.sW,
//                             height: 48.sH,
//                             margin: EdgeInsets.only(right: 12.sSp),
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.qr_code_scanner,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: onClose,
//                             child: Container(
//                               width: 48.sW,
//                               height: 48.sH,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black, width: 2),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.close,
//                                 color: Colors.black,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 18.sSp),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                        //SizedBox(height: 40.sH),
//
//                         ...items.asMap().entries.map((entry) {
//                           final index = entry.key;
//                           final item = entry.value;
//                           return Column(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => onItemTap(index),
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: EdgeInsets.symmetric(vertical: 14.sSp),
//                                   child: Text(
//                                     item,
//                                     style: TextStyleHelper.instance.headline28BoldInter.copyWith(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w900 ,
//
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 height: 2,
//                                 color: Colors.black,
//                                 margin: EdgeInsets.only(bottom: 16.sSp),
//                               ),
//                             ],
//                           );
//                         }).toList(),
//
//                         SizedBox(height: 20.sH),
//
//                         GestureDetector(
//                           onTap: onLanguageToggle,
//                           child: Container(
//                             width: double.infinity,
//                             //padding: EdgeInsets.symmetric(vertical: 24.sSp),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Language',
//                                   style: TextStyleHelper.instance.headline28BoldInter.copyWith(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w900 ,
//                                   ),
//                                 ),
//                                 Icon(
//                                   isLanguageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                                   color: Colors.black,
//                                   size: 32,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         if (isLanguageExpanded)
//                           Padding(
//                             padding: EdgeInsets.only(left: 20.sSp, top: 16.sSp),
//                             child: Column(
//                               children: languages.map((language) {
//                                 final isSelected = language['code'] == currentLang['code'];
//                                 return GestureDetector(
//                                   onTap: () => onLanguageSelect(language),
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(vertical: 16.sSp),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           language['flag']!,
//                                           style: TextStyle(fontSize: 32.sSp),
//                                         ),
//                                         SizedBox(width: 20.sSp),
//                                         Expanded(
//                                           child: Text(
//                                             language['name']!,
//                                             style: TextStyleHelper.instance.headline20BoldInter.copyWith(
//                                               color: Colors.black,
//                                               fontSize: 20.sSp,
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           width: 32.sW,
//                                           height: 32.sH,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             border: Border.all(
//                                               color: Colors.black,
//                                               width: 2,
//                                             ),
//                                             color: isSelected ? Colors.black : Colors.transparent,
//                                           ),
//                                           child: isSelected
//                                               ? Icon(
//                                             Icons.circle,
//                                             color: Colors.white,
//                                             size: 16.sSp,
//                                           )
//                                               : null,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//
//                         Container(
//                           height: 2,
//                           color: Colors.black,
//                           margin: EdgeInsets.symmetric(vertical: 16.sSp),
//                         ),
//
//                         const Spacer(),
//
//                         BlocBuilder<AuthCubit, AuthState>(
//                           builder: (context, state) {
//                             final isAuthenticated = state is AuthAuthenticated;
//
//                             if (!isAuthenticated) {
//                               return Container(
//                                 width: double.infinity,
//                                 margin: EdgeInsets.only(bottom: 40.sH),
//                                 child: GestureDetector(
//                                   onTap: onLoginTap,
//                                   child: Container(
//                                     height: 80.sH,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.black,
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         'Login',
//                                         style: TextStyleHelper.instance.headline24BoldInter.copyWith(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
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
    this.brand = 'ithra',
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
  final String brand;
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
          brand: brand,
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
                  brand,
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
