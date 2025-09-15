import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/presentation/view/home_tablet_view.dart';
import 'logic/login_cubit/login_cubit.dart';
import 'logic/login_cubit/login_states.dart';

class OAuthCallbackPage extends StatelessWidget {
  const OAuthCallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeTabletView()),
          );
        } else if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: context.read<LoginCubit>().handleOAuthCallback(),
            builder: (context, snapshot) {
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
