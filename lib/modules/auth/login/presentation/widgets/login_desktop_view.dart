import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/auth/login/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../home/presentation/view/home_tablet_view.dart';
import '../../../logic/login_cubit/login_cubit.dart';
import '../../../logic/login_cubit/login_states.dart';

class loginDesktop extends StatelessWidget {
  const loginDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final maxFormWidth = 800.sW;

    return BlocListener<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeTabletView()),
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Login successful!'),
          //     backgroundColor: AppColor.black,
          //   ),
          // );
        } else if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColor.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  color: AppColor.backgroundWhite,
                  padding: EdgeInsets.all(32.sW),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAssetsManager.appLogo, width: 120.sW,height: 120.sH,),
                        Text("ithra",style: TextStyleHelper.instance.display48BlackBoldInter),
                        SizedBox(height: 10.sH),
                        Text('Welcome to Ithra',
                            style: TextStyleHelper.instance.headline32BoldInter),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side (form)
              Expanded(
                flex: 7,
                child: Container(
                  color: AppColor.white,
                  child: Center(
                    child: SingleChildScrollView(
                      child: loginForm(width: maxFormWidth),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
