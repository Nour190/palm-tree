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

class AccountSettingsDesktopLayout extends StatelessWidget {
  const AccountSettingsDesktopLayout({super.key});

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

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Navigation/Sidebar (optional for future expansion)
            Container(
              width: 250.sW,
              padding: EdgeInsets.all(24.sW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyleHelper.instance.headline20BoldInter,
                  ),
                  SizedBox(height: 16.sH),
                  Container(
                    padding: EdgeInsets.all(12.sW),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: AppColor.primaryColor),
                        SizedBox(width: 8.sW),
                        Text(
                          'General',
                          style: TextStyleHelper.instance.title14BoldInter.copyWith(
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Column - Main Content
            Expanded(
              child: Container(
                padding: EdgeInsets.all(32.sW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'General Information',
                      style: TextStyleHelper.instance.headline24BoldInter,
                    ),
                    SizedBox(height: 8.sH),
                    Text(
                      'Update your account details and profile picture',
                      style: TextStyleHelper.instance.title16RegularInter.copyWith(
                        color: AppColor.gray400,
                      ),
                    ),
                    SizedBox(height: 32.sH),

                    // Content Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Section
                        Column(
                          children: [
                            AccountSettingsAvatar(
                              avatarUrl: profile.avatarUrl,
                              size: 120.sW,
                              onAvatarTap: () => _showAvatarOptions(context),
                            ),
                            SizedBox(height: 16.sH),
                            TextButton(
                              onPressed: () => _showAvatarOptions(context),
                              child: Text(
                                'Change Photo',
                                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 48.sW),

                        // Form Section
                        const Expanded(
                          child: AccountSettingsForm(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showAvatarOptions(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Change Profile Picture'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Take Photo'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage(context, ImageSource.camera);
  //
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text('Choose from Gallery'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage(context, ImageSource.gallery);
  //             },
  //           ),
  //           if (context.read<AccountSettingsCubit>().currentProfile?.avatarUrl != null)
  //             ListTile(
  //               leading: const Icon(Icons.delete, color: Colors.red),
  //               title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 //_removeAvatar(context);
  //               },
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showAvatarOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            // if (context.read<AccountSettingsCubit>().currentProfile?.avatarUrl != null)
            //   ListTile(
            //     leading: const Icon(Icons.delete, color: Colors.red),
            //     title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
            //     onTap: () {
            //       Navigator.pop(dialogContext);
            //       // call remove using outer context
            //       context.read<AccountSettingsCubit>().removeAvatar();
            //     },
            //   ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      print("upload **************");
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("upload **************20");
        // Handle web vs mobile/desktop differently as per user requirement
        XFile imagePath;
        if (kIsWeb) {
          print("upload **************web");
          // For web, use the path directly (it's a blob URL)
          //imagePath = pickedFile.path;
          imagePath = pickedFile;

        } else {
          // For mobile/desktop, use the file path
          imagePath = pickedFile;
        }

        // Update avatar using the cubit
        if (context.mounted) {
          print("upload **************2");
          context.read<AccountSettingsCubit>().updateAvatar(imagePath);
        }
      }
    } catch (e) {
      print("upload **************error");
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
  //     context.read<AccountSettingsCubit>().updateAvatar(_);
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
