import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/responsive/responsive.dart';
// import '../../../../home/presentation/view/home_tablet_view.dart';
import '../../../../tabs/presentation/view/tabs_view.dart';
import '../../../logic/auth_gate_cubit/auth_cubit.dart';
import '../../../logic/login_cubit/login_cubit.dart';
import '../../../logic/login_cubit/login_states.dart';
import '../../../signup/presentation/view/signup_screen.dart';


class loginMobileTablet extends StatefulWidget {
  const loginMobileTablet({super.key});

  @override
  State<loginMobileTablet> createState() => _loginMobileTabletState();
}

class _loginMobileTabletState extends State<loginMobileTablet> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<LoginCubit>();
    cubit.startAuthListener();
    //cubit.checkInitialAuthState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
 //   final formWidth = isMobile ? 340.w : 480.w;
    return BlocListener<LoginCubit, LoginStates>(

    listener: (context, state) {
      if (state is LoginSuccessState) {

        context.read<AuthCubit>().notifyLoggedIn();
      }
      if (state is LoginErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColor.red,
          ),
        );
      } else if (state is LoginRedirectingState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redirecting to Google for sign in...')),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    Center(
                      child: Image.asset(
                        AppAssetsManager.appLogo,
                        width: isMobile ? 80.w : 120.w,
                        height: isMobile ? 80.h : 120.h,
                      ),
                    ),
                    Text("ithra", style: TextStyleHelper.instance.display48BlackBoldInter),
                    SizedBox(height: 15.h),
                    loginForm(
                      width: double.infinity,
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
    )
    );
  }
}
