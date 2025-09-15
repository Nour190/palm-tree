// import 'package:baseqat/core/resourses/color_manager.dart';
// import 'package:baseqat/core/responsive/size_utils.dart';
// import 'package:baseqat/modules/auth/signup/presentation/widgets/login_form.dart';
// import 'package:flutter/material.dart';
//
// class SignupTabletView extends StatelessWidget {
//   const SignupTabletView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverFillRemaining(
//           hasScrollBody: false,
//           child: Stack(
//             children: [
//               Positioned(
//                 top: -50.h,
//                 right: -50.w,
//                 child: Container(
//                   width: 250.w,
//                   height: 250.h,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColor.gray400, width: 2),
//                     borderRadius: BorderRadius.circular(125.h),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 150.h,
//                 left: -150.w,
//                 child: Container(
//                   width: 400.w,
//                   height: 400.h,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColor.gray400, width: 2),
//                     borderRadius: BorderRadius.circular(200.h),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -150.h,
//                 right: -200.w,
//                 child: Container(
//                   width: 500.w,
//                   height: 500.h,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColor.gray400, width: 2),
//                     borderRadius: BorderRadius.circular(250.h),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 32.h),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Center(
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(maxWidth: 500.w),
//                           child: const SignupForm(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
