import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/components/custom_widgets/custom_text_field.dart';
import 'package:baseqat/core/components/custom_widgets/custom_button.dart';
import '../../../../core/components/custom_widgets/auth_button.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';

class AccountSettingsForm extends StatefulWidget {
  const AccountSettingsForm({super.key});

  @override
  State<AccountSettingsForm> createState() => _AccountSettingsFormState();
}

class _AccountSettingsFormState extends State<AccountSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final cubit = context.read<AccountSettingsCubit>();
    final currentProfile = cubit.currentProfile;
    
    if (currentProfile != null) {
      final hasChanges = _nameController.text.trim() != currentProfile.name;
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountSettingsCubit, AccountSettingsState>(
      listener: (context, state) {
        if (state is AccountSettingsLoaded || state is AccountSettingsSuccess) {
          final profile = context.read<AccountSettingsCubit>().currentProfile;
          if (profile != null && _nameController.text != profile.name) {
            _nameController.text = profile.name;
          }
        }
      },
      child: BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
        builder: (context, state) {
          final profile = context.read<AccountSettingsCubit>().currentProfile;
          final isLoading = state is AccountSettingsSaving;
          if (profile == null) {
            return const SizedBox.shrink();
          }
          // Initialize controller if empty
          if (_nameController.text.isEmpty) {
            _nameController.text = profile.name;
          }

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                Text(
                  'Full Name',
                  style: TextStyleHelper.instance.title14BoldInter,
                ),
                SizedBox(height: 8.sH),
                CustomTextFormField(
                  initialValue: profile.name,
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length > 50) {
                      return 'Name cannot exceed 50 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.sH),

                // Email Field (Read-only)
                Text(
                  'Email Address',
                  style: TextStyleHelper.instance.title14BoldInter,
                ),
                SizedBox(height: 8.sH),
                CustomTextFormField(
                  initialValue: profile.email,
                  hintText: 'Email address',
                  enabled: false,
                  suffixIcon: Tooltip(
                    message: 'Email is verified — cannot be changed here.',
                    child: Icon(
                      Icons.info_outline,
                      color: AppColor.gray400,
                      size: 20.sSp,
                    ),
                  ),
                ),
                SizedBox(height: 20.sH),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: AuthButton(
                    text: isLoading ? 'Saving...' : 'Save Changes',
                    onPressed: _hasChanges && !isLoading ? _saveChanges : null,
                    //isLoading: isLoading,
                  ),
                ),

                // if (_hasChanges) ...[
                //   SizedBox(height: 8.sH),
                //   TextButton(
                //     onPressed: isLoading ? null : _resetChanges,
                //     child: Text(
                //       'Cancel',
                //       style: TextStyleHelper.instance.body14RegularInter.copyWith(
                //         color: AppColor.gray400,
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AccountSettingsCubit>().updateName(_nameController.text.trim());
    }
  }

  void _resetChanges() {
    final profile = context.read<AccountSettingsCubit>().currentProfile;
    if (profile != null) {
      _nameController.text = profile.name;
    }
  }
}
