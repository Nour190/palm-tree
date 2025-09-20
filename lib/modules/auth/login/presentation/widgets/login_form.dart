import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/components/custom_widgets/custom_text_field.dart';
import '../../../../../core/components/custom_widgets/auth_button.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/components/custom_widgets/social_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/login_cubit/login_cubit.dart';
import '../../../logic/login_cubit/login_states.dart';
import '../../../../../../modules/auth/signup/presentation/view/signup_screen.dart';

class loginForm extends StatefulWidget {
  const loginForm({super.key, this.width, this.onSubmit});

  final double? width;
  final void Function(String email, String password)? onSubmit;

  @override
  State<loginForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<loginForm> {
  final _formKey = GlobalKey<FormState>();
  /// Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<LoginCubit>();
      cubit.emailController.text = _emailController.text.trim();
      cubit.passwordController.text = _passwordController.text;
      cubit.login();
    }
  }

  void _signInWithGoogle() {
    final cubit = context.read<LoginCubit>();
    cubit.signInWithGoogle();
  }

  void _signInWithApple() {
    // TODO: Implement Apple Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: EdgeInsets.all(18.sW),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome', style: TextStyleHelper.instance.headline32BoldInter),
            SizedBox(height: 10.sH),
            Text(
              "Enter your email to get started.",
              style: TextStyleHelper.instance.title16BlackRegularInter,
            ),
            SizedBox(height: 30.sH),

            /// Email
            CustomTextFormField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email field is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 16.sH),

            /// Password
            CustomTextFormField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
              validator: (value) => value == null || value.isEmpty
                  ? 'Password field is required'
                  : null,
            ),
            SizedBox(height: 20.sH),

            /// Submit Button
            BlocBuilder<LoginCubit, LoginStates>(
              builder: (context, state) {
                final isLoading = state is LoginLoadingState;
                return AuthButton(
                  text: isLoading ? 'Logging in...' : 'Login',
                  onPressed: isLoading ? null : _submitForm,
                );
              },
            ),

            SizedBox(height: 16.sH),

            /// Social Logins
            BlocBuilder<LoginCubit, LoginStates>(
              builder: (context, state) {
                final isGoogleLoading = state is LoginWithGoogleLoadingState;
                return SocialButton(
                  text: isGoogleLoading ? 'Signing in with Google...' : 'login with Google',
                  imageAsset: AppAssetsManager.googleLogo,
                  onPressed: isGoogleLoading ? () {} : _signInWithGoogle,
                );
              },
            ),
            SizedBox(height: 14.sH),
            SocialButton(
              text: 'login with Apple',
              imageAsset: AppAssetsManager.appleLogo,
              onPressed: _signInWithApple,
            ),

            SizedBox(height: 20.sH),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create an new account ?', style: TextStyleHelper.instance.title16BlackRegularInter),
                SizedBox(width: 6.sW),
                GestureDetector(
                  onTap: _navigateToSignUp,
                  child: Text(
                    'Create',
                    style: TextStyleHelper.instance.title16BoldInter,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: widget.width != null && widget.width! > 340
                  ? 100.sH // Reduced from 100.sH for better proportions
                  : 12.sH, // Small spacing for smaller screens
            ),
          ],
        ),
      ),
    );
  }
}
