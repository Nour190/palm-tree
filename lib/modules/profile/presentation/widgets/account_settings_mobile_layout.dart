import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';
import 'account_settings_form.dart';
import 'account_settings_avatar.dart';
class AccountSettingsMobileLayout extends StatelessWidget {
  const AccountSettingsMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
      builder: (context, state) {
        if (state is AccountSettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountSettingsError && state.profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load profile',
                  style: TextStyleHelper.instance.title16RegularInter,
                ),
                SizedBox(height: 16.sH),
                ElevatedButton(
                  onPressed: () {
                    // Retry loading profile
                    final userId = context.read<AccountSettingsCubit>().currentProfile?.id;
                    if (userId != null) {
                      context.read<AccountSettingsCubit>().loadProfile(userId);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final profile = context.read<AccountSettingsCubit>().currentProfile;
        if (profile == null) {
          return const Center(child: Text('No profile data available'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.sW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'General Information',
                style: TextStyleHelper.instance.title18BoldInter,
              ),
              SizedBox(height: 8.sH),
              Text(
                'Update your account details and profile picture',
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: AppColor.gray400,
                ),
              ),
              SizedBox(height: 24.sH),

              // Avatar Section
              Center(
                child: AccountSettingsAvatar(
                  avatarUrl: profile.avatarUrl,
                  onAvatarTap: () => _showAvatarOptions(context),
                ),
              ),
              SizedBox(height: 32.sH),

              // Form Section
              const AccountSettingsForm(),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.sW),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.camera_alt),
            //   title:  Text('Take Photo',style: TextStyleHelper.instance.title16MediumInter),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _pickImage(context, ImageSource.camera);
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title:  Text('Choose from Gallery',style: TextStyleHelper.instance.title16MediumInter,),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            if (context.read<AccountSettingsCubit>().currentProfile?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  //_removeAvatar(context);
                },
              ),
          ],
        ),
      ),
    );
  }
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        // Handle web vs mobile/desktop differently as per user requirement
        XFile imagePath;
        if (kIsWeb) {
       //   imagePath = Image.network(pickedFile.path);
          // For web, use the path directly (it's a blob URL)
          imagePath = pickedFile;
        } else {
          // For mobile/desktop, use the file path
          imagePath = pickedFile;
        }
        // Update avatar using the cubit
        if (context.mounted) {
          context.read<AccountSettingsCubit>().updateAvatar(imagePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _removeAvatar(BuildContext context) async {
  //   try {
  //     // Update avatar with empty string to remove it
  //     context.read<AccountSettingsCubit>().updateAvatar('');
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to remove avatar: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
}
