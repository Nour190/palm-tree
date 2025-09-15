import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../logic/login_cubit/login_cubit.dart';
import '../../../logic/login_cubit/login_states.dart';
import '../../../signup/presentation/view/signup_screen.dart';


class loginMobileTablet extends StatelessWidget {
  const loginMobileTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final formWidth = isMobile ? 340.w : 480.w;

    return Scaffold(
      body: SafeArea(
        child: BlocListener<LoginCubit, LoginStates>(
          listener: (context, state) {
            if (state is LoginSuccessState) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Login successful!')),
              // );
              // Navigate to home screen or dashboard
            } else if (state is LoginErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: ${state.errorMessage}')),
              );
            }
          },
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
                        loginForm(
                          width: formWidth,
                          onSubmit: (email, password) {
                            final cubit = context.read<LoginCubit>();
                            cubit.emailController.text = email;
                            cubit.passwordController.text = password;
                            cubit.login();
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
      ),
    );
  }
}
