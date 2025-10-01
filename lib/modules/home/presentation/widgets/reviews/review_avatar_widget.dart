import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:flutter/material.dart';

class ReviewAvatarWidget extends StatelessWidget {
  const ReviewAvatarWidget({
    super.key,
    required this.name,
    required this.gender,
    required this.avatarUrl,
    this.overrideSize,
  });

  final String name;
  final String gender;
  final String avatarUrl;
  final double? overrideSize;

  @override
  Widget build(BuildContext context) {
    final size =
        overrideSize ?? (Responsive.isDesktop(context) ? 100.sH : 80.sH);

    return Container(
      width: 65.sW,
      height: 90.sH,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.3),
            blurRadius: 20.sH,
            offset: Offset(0, 10.sH),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            final total = progress.expectedTotalBytes;
            final value = total != null && total != 0
                ? progress.cumulativeBytesLoaded / total
                : null;
            return _loading(size, value);
          },
          errorBuilder: (context, error, stackTrace) =>
              _fallback(size, context),
        ),
      ),
    );
  }

  Widget _fallback(double size, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.gray600, AppColor.gray700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.w700,
            fontSize: Responsive.isDesktop(context) ? 36.sSp : 28.sSp,
          ),
        ),
      ),
    );
  }

  Widget _loading(double size, double? progress) {
    return Container(
      decoration: BoxDecoration(color: AppColor.gray100),
      child: Center(
        child: SizedBox(
          width: size * 0.32,
          height: size * 0.32,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
