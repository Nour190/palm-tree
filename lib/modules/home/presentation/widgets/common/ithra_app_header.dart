// import 'package:flutter/material.dart';
// import 'package:baseqat/core/responsive/responsive.dart';
// import 'package:baseqat/core/responsive/size_ext.dart';
// import 'package:baseqat/core/resourses/color_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
//
// class IthraAppHeader extends StatelessWidget {
//   final VoidCallback? onMenuTap;
//   final VoidCallback? onSearchTap;
//   final VoidCallback? onNotificationTap;
//
//   const IthraAppHeader({
//     super.key,
//     this.onMenuTap,
//     this.onSearchTap,
//     this.onNotificationTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceType = Responsive.deviceTypeOf(context);
//     final bool isMobile = deviceType == DeviceType.mobile;
//     final bool isTablet = deviceType == DeviceType.tablet;
//     final bool isDesktop = deviceType == DeviceType.desktop;
//
//     final double horizontalPadding = isDesktop
//         ? 48.sW
//         : isTablet
//         ? 32.sW
//         : 18.sW;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         horizontalPadding,
//         MediaQuery.of(context).padding.top + 16.sH,
//         horizontalPadding,
//         16.sH,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFF0F0F0),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Logo and brand name
//           Row(
//             children: [
//               // Ithra logo icon
//               Container(
//                 width: isMobile ? 24.sW : 28.sW,
//                 height: isMobile ? 24.sW : 28.sW,
//                 decoration: BoxDecoration(
//                   color: AppColor.black,
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//                 child: Icon(
//                   Icons.location_on,
//                   color: Colors.white,
//                   size: isMobile ? 14.sW : 16.sW,
//                 ),
//               ),
//               SizedBox(width: 8.sW),
//               // Brand name
//               Text(
//                 'ithra',
//                 style: TextStyle(
//                   fontFamily: 'Inter',
//                   fontSize: isMobile ? 18.sSp : 20.sSp,
//                   fontWeight: FontWeight.w700,
//                   color: AppColor.black,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ],
//           ),
//
//           const Spacer(),
//
//           // Navigation icons
//           Row(
//             children: [
//               // Search icon
//               _HeaderIconButton(
//                 icon: Icons.search_rounded,
//                 onTap: onSearchTap,
//                 size: isMobile ? 20.sW : 22.sW,
//               ),
//               SizedBox(width: isMobile ? 12.sW : 16.sW),
//
//               // Menu/hamburger icon
//               _HeaderIconButton(
//                 icon: Icons.menu_rounded,
//                 onTap: onMenuTap,
//                 size: isMobile ? 20.sW : 22.sW,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _HeaderIconButton extends StatefulWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   final double size;
//
//   const _HeaderIconButton({
//     required this.icon,
//     this.onTap,
//     required this.size,
//   });
//
//   @override
//   State<_HeaderIconButton> createState() => _HeaderIconButtonState();
// }
//
// class _HeaderIconButtonState extends State<_HeaderIconButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) => _controller.reverse(),
//       onTapCancel: () => _controller.reverse(),
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _scaleAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Container(
//               width: 40.sW,
//               height: 40.sW,
//               decoration: BoxDecoration(
//                 color: AppColor.gray50,
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(
//                   color: AppColor.gray200,
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 widget.icon,
//                 size: widget.size,
//                 color: AppColor.gray700,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
