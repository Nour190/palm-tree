import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/auth/signup/presentation/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/register_cubit/register_cubit.dart';
import '../../../logic/register_cubit/register_states.dart';

class SignUpDesktop extends StatelessWidget {
  const SignUpDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final maxFormWidth = 800.sW;

    return BlocListener<RegisterCubit, RegisterStates>(
      listener: (context, state) {
        if (state is RegisterSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: AppColor.black,
            ),
          );
        } else if (state is RegisterErrorState) {
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
                    child: SingleChildScrollView(child: SignUpForm(width: maxFormWidth)),
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


