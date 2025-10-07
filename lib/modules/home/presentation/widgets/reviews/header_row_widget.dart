// import 'package:baseqat/core/resourses/color_manager.dart';
// import 'package:baseqat/core/resourses/style_manager.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
//
// class HeaderRowWidget extends StatelessWidget {
//   const HeaderRowWidget({super.key, required this.isDesktop});
//   final bool isDesktop;
//
//   @override
//   Widget build(BuildContext context) {
//     final styles = TextStyleHelper.instance;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(
//           child: Text(
//             'home.reviews'.tr(),
//             textAlign: TextAlign.left,
//             style: styles.headline20BoldInter.copyWith(
//               color: AppColor.whiteCustom,
//               height: 1.15,
//             ),
//           ),
//         ),
//         if (!isDesktop)
//           Text(
//             'Swipe',
//             style: styles.body14RegularInter.copyWith(
//               color: AppColor.gray400,
//               height: 1.2,
//             ),
//           ),
//       ],
//     );
//   }
// }
