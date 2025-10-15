import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import '../../resourses/color_manager.dart';
import '../../resourses/style_manager.dart';
import '../../network/connectivity_service.dart';
import 'dart:ui' as ui;


class DesktopLanguageSwitcher extends StatelessWidget {
  const DesktopLanguageSwitcher({super.key});

  static const List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'code': 'en', 'locale': Locale('en', 'US'), 'flag': '🇺🇸'},
    {'name': 'العربية', 'code': 'ar', 'locale': Locale('ar', 'SA'), 'flag': '🇸🇦'},
    {'name': 'Deutsch', 'code': 'de', 'locale': Locale('de', 'DE'), 'flag': '🇩🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = _languages.firstWhere(
          (lang) => lang['code'] == context.locale.languageCode,
      orElse: () => _languages[0],
    );

    final connectivityService = ConnectivityService();

    return PopupMenuButton<Map<String, dynamic>>(
      onSelected: (lang) async {
        final hasConnection = await connectivityService.hasConnection();

        if (!hasConnection) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('common.offline_language_change'.tr()),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        await context.setLocale(lang['locale']);
      },
      offset: Offset(0, 40.sH),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.sH),
      ),
      itemBuilder: (context) => _languages.map((lang) {
        final isSelected = lang['code'] == context.locale.languageCode;
        return PopupMenuItem<Map<String, dynamic>>(
          value: lang,
          child: Row(
            children: [
              Text(
                lang['flag'],
                style: TextStyle(fontSize: 16.sSp),
                textDirection: ui.TextDirection.ltr, // Emojis render best in LTR
              ),
              SizedBox(width: 8.sSp),
              Text(
                lang['name'],
                style: TextStyleHelper.instance.title14MediumInter.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColor.gray900 : AppColor.gray600,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 16.sSp,
                  color: AppColor.gray900,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        height: 36.sH,
        padding: EdgeInsets.symmetric(horizontal: 12.sSp),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          borderRadius: BorderRadius.circular(6.sH),
          border: Border.all(color: AppColor.gray200, width: 1.sW),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang['flag'],
              style: TextStyle(fontSize: 14.sSp),
              textDirection: ui.TextDirection.ltr, // Emojis render best in LTR
            ),
            SizedBox(width: 6.sSp),
            Text(
              currentLang['code'].toString().toUpperCase(),
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: AppColor.gray700,
              ),
            ),
            SizedBox(width: 4.sSp),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sSp,
              color: AppColor.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact language switcher for mobile/tablet top bars
/// Follows mobile UI patterns with bottom sheet selection
class MobileLanguageSwitcher extends StatelessWidget {
  const MobileLanguageSwitcher({super.key});

  static const List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'code': 'en', 'locale': Locale('en', 'US'), 'flag': '🇺🇸'},
    {'name': 'العربية', 'code': 'ar', 'locale': Locale('ar', 'SA'), 'flag': '🇸🇦'},
    {'name': 'Deutsch', 'code': 'de', 'locale': Locale('de', 'DE'), 'flag': '🇩🇪'},
  ];

  void _showLanguageSheet(BuildContext context) async {
    final connectivityService = ConnectivityService();
    final hasConnection = await connectivityService.hasConnection();

    if (!hasConnection) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.offline_language_change'.tr()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.sH)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.sH),
              Container(
                width: 40.sW,
                height: 4.sH,
                decoration: BoxDecoration(
                  color: AppColor.gray400,
                  borderRadius: BorderRadius.circular(4.sH),
                ),
              ),
              SizedBox(height: 16.sH),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sSp),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 20.sSp,
                      color: AppColor.gray700,
                    ),
                    SizedBox(width: 8.sSp),
                    Text(
                      'common.select_language'.tr(),
                      style: TextStyleHelper.instance.title16BoldInter,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sH),
              ..._languages.map((lang) {
                final isSelected = lang['code'] == context.locale.languageCode;
                return ListTile(
                  leading: Text(
                    lang['flag'],
                    style: TextStyle(
                      fontSize: 20.sSp,
                      fontFamily: null, // Use system emoji font
                    ),
                    textDirection: ui.TextDirection.ltr, // Emojis render best in LTR
                  ),
                  title: Text(
                    lang['name'],
                    style: TextStyleHelper.instance.title16RegularInter.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                    Icons.check_circle,
                    color: AppColor.primaryColor,
                    size: 20.sSp,
                  )
                      : null,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.setLocale(lang['locale']);
                  },
                );
              }).toList(),
              SizedBox(height: 16.sH),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = _languages.firstWhere(
          (lang) => lang['code'] == context.locale.languageCode,
      orElse: () => _languages[0],
    );

    return InkWell(
      onTap: () => _showLanguageSheet(context),
      borderRadius: BorderRadius.circular(20.sH),
      child: Container(
        width: 40.sW,
        height: 40.sH,
        decoration: BoxDecoration(
          color: AppColor.gray100,
          borderRadius: BorderRadius.circular(20.sH),
          border: Border.all(color: AppColor.gray400, width: 1.sW),
        ),
        child: Center(
          child: Text(
            currentLang['flag'],
            style: TextStyle(
              fontSize: 18.sSp,
              fontFamily: null, // Use system emoji font
            ),
            textDirection: ui.TextDirection.ltr, // Emojis render best in LTR
          ),
        ),
      ),
    );
  }
}
