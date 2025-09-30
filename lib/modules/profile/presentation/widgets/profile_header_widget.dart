import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/profile/presentation/cubit/account_settings_cubit.dart';
import 'package:baseqat/modules/profile/presentation/cubit/account_settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
      builder: (context, state) {
        // Get profile data from cubit state
        final profile = context.read<AccountSettingsCubit>().currentProfile;
        final isLoading = state is AccountSettingsLoading;

        return Column(
          children: [
            // Profile Avatar
            Container(
              width: 100.sW,
              height: 100.sW,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.gray400, width: 2),
              ),
              child: ClipOval(
                child: isLoading
                    ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.gray.withOpacity(0.3),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                    ? Image.network(
                  profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
                    : _buildDefaultAvatar(),
              ),
            ),

            SizedBox(height: 14.sH),

            // Profile Name
            isLoading
                ? Container(
              width: 120.sW,
              height: 24.sH,
              decoration: BoxDecoration(
                color: AppColor.gray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4.sW),
              ),
            )
                : Text(
              profile?.name ?? 'User',
              style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                color: AppColor.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.person,
        size: 50.sW,
        color: AppColor.primaryColor,
      ),
    );
  }
}
