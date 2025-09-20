import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/components/custom_widgets/custom_text_field.dart';
import '../../../../../core/components/custom_widgets/auth_button.dart';
import '../../../../../core/components/custom_widgets/social_button.dart';
import '../../../../../core/resourses/assets_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/resourses/color_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/register_cubit/register_cubit.dart';
import '../../../logic/register_cubit/register_states.dart';
import '../../../../../../modules/auth/login/presentation/view/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, this.width, this.onSubmit});

  final double? width;
  final void Function(String name, String email, String password)? onSubmit;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  /// Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<RegisterCubit>();
      cubit.nameController.text = _nameController.text.trim();
      cubit.emailController.text = _emailController.text.trim();
      cubit.passwordController.text = _passwordController.text;
      cubit.register();
    }
  }


  void _signUpWithGoogle() {
    final cubit = context.read<RegisterCubit>();
    cubit.signUpWithGoogle();
  }


  void _signUpWithApple() {
    // TODO: Implement Apple Sign-Up
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-Up not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const loginScreen()),
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
            Text('Create an account', style: TextStyleHelper.instance.headline32BoldInter),
            SizedBox(height: 10.sH),
            Text(
              "Let's get started with your free version",
              style: TextStyleHelper.instance.title16BlackRegularInter,
            ),
            SizedBox(height: 30.sH),

            /// Name
            CustomTextFormField(
              controller: _nameController,
              hintText: 'Name',
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            SizedBox(height: 16.sH),

            /// Email
            CustomTextFormField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
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
              validator: (value) => value != null && value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            SizedBox(height: 20.sH),

            /// Submit Button
            BlocBuilder<RegisterCubit, RegisterStates>(
              builder: (context, state) {
                final isLoading = state is RegisterLoadingState;
                return AuthButton(
                  text: isLoading ? 'Creating account...' : 'Create account',
                  onPressed: isLoading ? null : () => _submitForm(),
                );
              },
            ),

            SizedBox(height: 16.sH),

            /// Social Logins
            /// Social Logins
            BlocBuilder<RegisterCubit, RegisterStates>(
              builder: (context, state) {
                final isGoogleLoading = state is RegisterWithGoogleLoadingState;
                return SocialButton(
                  text: isGoogleLoading ? 'Signing up with Google...' : 'Sign up with Google',
                  imageAsset: AppAssetsManager.googleLogo,
                  onPressed: isGoogleLoading ? (){} : _signUpWithGoogle,
                );
              },
            ),
            SizedBox(height: 14.sH),
            SocialButton(
              text: 'Sign up with Apple',
              imageAsset: AppAssetsManager.appleLogo,
              onPressed: _signUpWithApple,
            ),

            SizedBox(height: 20.sH),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have account ?', style: TextStyleHelper.instance.title16BlackRegularInter),
                SizedBox(width: 6.sW),
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
                    'Login',
                    style: TextStyleHelper.instance.title16BoldInter,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: widget.width != null && widget.width! > 340
                  ? 24.sH
                  : 12.sH,
            ),
          ],
        ),
      ),
    );
  }
}
