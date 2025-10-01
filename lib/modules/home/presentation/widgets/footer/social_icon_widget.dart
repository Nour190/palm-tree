import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialIconWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const SocialIconWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;

    final iconSize = isMobile ? 36.sW : 48.sW;
    final iconInnerSize = isMobile ? 18.sW : 22.sW;

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: () => _handleSocialTap(label),
        borderRadius: BorderRadius.circular(iconSize / 2),
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColor.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColor.gray900, size: iconInnerSize),
        ),
      ),
    );
  }

  void _handleSocialTap(String platform) async {
    final urls = {
      'Facebook':
          'https://www.facebook.com/KingAbdulazizCenterForWorldCulture/',
      'LinkedIn':
          'https://www.linkedin.com/company/kingabdulazizcenterforworldculture',
      'X (Twitter)':
          'https://x.com/Ithra?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor',
    };

    final url = urls[platform];
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
