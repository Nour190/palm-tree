import 'package:baseqat/modules/auth/signup/presentation/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/responsive/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../home/presentation/view/home_tablet_view.dart';
import '../../../../tabs/presentation/view/tabs_view.dart';
import '../../../logic/auth_gate_cubit/auth_cubit.dart';
import '../../../logic/register_cubit/register_cubit.dart';
import '../../../logic/register_cubit/register_states.dart';

// class SignUpMobileTablet extends StatelessWidget {
//   const SignUpMobileTablet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final isMobile = Responsive.isMobile(context);
//     final formWidth = isMobile ? 340.w : 480.w;
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
//               child: Column(
//                 children: [
//                   SizedBox(height: 24.h),
//                   Image.asset(
//                     'assets/images/logo.png',
//                     width: isMobile ? 80.w : 120.w,
//                     height: isMobile ? 80.h : 120.h,
//                   ),
//                   SizedBox(height: 18.h),
//                   Text('Create an account', style: AppTextStyles.headline),
//                   SizedBox(height: 8.h),
//                   Text("Lets get started with your free version", style: AppTextStyles.subtitle),
//                   SizedBox(height: 28.h),
//                   Container(
//                     width: formWidth,
//                     padding: EdgeInsets.all(18.w),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.r),
//                       color: Colors.white,
//                     ),
//                     child: Column(
//                       children: [
//                         CustomTextFormField(hintText: 'Name'),
//                         SizedBox(height: 12.h),
//                         CustomTextFormField(hintText: 'Email', keyboardType: TextInputType.emailAddress),
//                         SizedBox(height: 12.h),
//                         CustomTextFormField(hintText: 'Password', obscureText: true),
//                         SizedBox(height: 18.h),
//                         AuthButton(text: 'Create account', onPressed: () {}),
//                         SizedBox(height: 14.h),
//                         SocialButton(text: 'Sign up with Google', imageAsset: 'assets/images/google.png', onPressed: () {}),
//                         SizedBox(height: 12.h),
//                         SocialButton(text: 'Sign up with Apple', imageAsset: 'assets/images/apple.png', onPressed: () {}),
//                         SizedBox(height: 18.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text('Already have account ?', style: AppTextStyles.small),
//                             SizedBox(width: 6.w),
//                             GestureDetector(
//                               onTap: () {},
//                               child: Text('Login', style: AppTextStyles.small.copyWith(fontWeight: FontWeight.bold)),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 40.h),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



class SignUpMobileTablet extends StatefulWidget {
  const SignUpMobileTablet({super.key});

  @override
  State<SignUpMobileTablet> createState() => _SignUpMobileTabletState();
}

class _SignUpMobileTabletState extends State<SignUpMobileTablet> {
  @override
  void initState() {
    super.initState();
    // call cubit to start listener and check redirect
    Future.microtask(() {
      final cubit = context.read<RegisterCubit>();
      cubit.startAuthListener();
      cubit.checkInitialAuthState();
    });
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final formWidth = isMobile ? 340.w : 480.w;

    return  BlocListener<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Registration successful!'), backgroundColor: AppColor.black),
            // );
            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(builder: (context) => const TabsViewScreen()),
            //       (Route<dynamic> route) => false,
            // );
            context.read<AuthCubit>().notifyLoggedIn();
          } else if (state is RegisterErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColor.red,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Redirecting to Google for sign up...')),
            );
          }
        },
    child:Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      Image.asset(
                        AppAssetsManager.appLogo,
                        width: isMobile ? 80.w : 120.w,
                        height: isMobile ? 80.h : 120.h,
                      ),
                      Text("ithra", style: TextStyleHelper.instance.display48BlackBoldInter),
                      SizedBox(height: 15.h),
                      SignUpForm(
                        width: formWidth,
                        onSubmit: (name, email, password) {
                          final cubit = context.read<RegisterCubit>();
                          cubit.nameController.text = name;
                          cubit.emailController.text = email;
                          cubit.passwordController.text = password;
                          cubit.register();
                        },
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
    );
  }
}
