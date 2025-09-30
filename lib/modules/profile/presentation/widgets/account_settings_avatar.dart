import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';

class AccountSettingsAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double? size;
  final VoidCallback? onAvatarTap;

  const AccountSettingsAvatar({
    super.key,
    this.avatarUrl,
    this.size,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? 80.sW;

    return BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
      builder: (context, state) {
        final isUploading = state is AccountSettingsAvatarUploading;

        return GestureDetector(
          onTap: isUploading ? null : onAvatarTap,
          child: Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.gray400,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(avatarSize);
                          },
                        )
                      : _buildDefaultAvatar(avatarSize),
                ),
              ),

              // Upload indicator
              if (isUploading)
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // Edit icon
             if (!isUploading)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28.sW,
                    height: 28.sW,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14.sSp,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColor.gray100,
      child: Icon(
        Icons.person,
        color: AppColor.gray400,
        size: size * 0.5,
      ),
    );
  }
}
