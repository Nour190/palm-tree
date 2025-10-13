import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'compact_locale_switcher.dart';

class DesktopTopBar extends StatelessWidget {
  DesktopTopBar({
    super.key,
    String? logoPath,
    this.brand ,
    required this.items,
    this.selectedIndex = 0,
    this.onItemTap,
    this.onLoginTap,
    this.showScanButton = true,
    this.onScanTap,
  }) : logoPath = logoPath ?? AppAssetsManager.imgLogo;

  final String logoPath;
  final String ?brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.sH,
      padding: EdgeInsets.symmetric(horizontal: 24.sSp),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(
          bottom: BorderSide(color: AppColor.gray200, width: 1.sW),
        ),
      ),
      child: Row(
        children: [
          // Logo and brand on the left
          _DesktopBrand(logoPath: logoPath, brand: brand?? "navigation.brand_name".tr(),),
          SizedBox(width: 48.sSp),

          // Navigation tabs in the center
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _DesktopNavTab(
                    items[i],
                    selected: i == selectedIndex,
                    onTap: () => onItemTap?.call(i),
                  ),
                  SizedBox(width: 32.sSp),
                ],
              ],
            ),
          ),

          // Actions on the right
          Row(
            children: [
              // Language switcher with desktop-familiar dropdown design
              const DesktopLanguageSwitcher(),
              SizedBox(width: 16.sSp),
              // if (showScanButton) ...[
              //   //_DesktopScanButton(onTap: onScanTap),
              //   SizedBox(width: 16.sSp),
              // ],
              _DesktopLoginButton(onTap: onLoginTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopBrand extends StatelessWidget {
  const _DesktopBrand({required this.logoPath, required this.brand});
  final String logoPath;
  final String brand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.sH),
          child: Container(
            width: 40.sW,
            height: 40.sH,
            color: AppColor.white,
            child: Image.asset(logoPath, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 12.sSp),
        Text(brand, style: TextStyleHelper.instance.headline24BoldInter),
      ],
    );
  }
}

class _DesktopNavTab extends StatelessWidget {
  const _DesktopNavTab(this.label, {required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.sH),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sSp, vertical: 8.sSp),
        decoration: BoxDecoration(
          border: selected
              ? Border(
            bottom: BorderSide(color: AppColor.gray900, width: 3.sW),
          )
              : null,
        ),
        child: Text(
          label,
          style: selected
              ? TextStyleHelper.instance.title16BoldInter.copyWith(
            color: AppColor.gray900,
          )
              : TextStyleHelper.instance.title16RegularInter.copyWith(
            color: AppColor.gray600,
          ),
        ),
      ),
    );
  }
}

class _DesktopLoginButton extends StatelessWidget {
  const _DesktopLoginButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.sH),
      onTap: onTap,
      child: Container(
        height: 40.sH,
        padding: EdgeInsets.symmetric(horizontal: 24.sSp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.gray900,
          borderRadius: BorderRadius.circular(8.sH),
        ),
        child: Text(
          "Login",
          style: TextStyleHelper.instance.title14MediumInter.copyWith(
            color: AppColor.white,
          ),
        ),
      ),
    );
  }
}

class _DesktopScanButton extends StatelessWidget {
  const _DesktopScanButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.sH),
      onTap: onTap,
      child: Container(
        width: 40.sW,
        height: 40.sH,
        decoration: BoxDecoration(
          color: AppColor.gray100,
          borderRadius: BorderRadius.circular(8.sH),
          border: Border.all(color: AppColor.gray400, width: 1.sW),
        ),
        child: const Center(
          child: Icon(Icons.qr_code_scanner, color: AppColor.gray700, size: 20),
        ),
      ),
    );
  }
}
