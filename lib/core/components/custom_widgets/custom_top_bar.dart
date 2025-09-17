import 'dart:math' as math;
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';

class TopBar extends StatelessWidget {
  TopBar({
    super.key,
    String? logoPath,
    this.brand = 'ithra',
    required this.items,
    this.selectedIndex = 0,
    this.onItemTap,
    this.onLoginTap,
    this.showScanButton = true,
    this.onScanTap,
    this.maxTabletItems = 4,
    this.compactOnMobile = true,
  }) : logoPath = logoPath ?? AppAssetsManager.imgLogo;

  final String logoPath;
  final String brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;

  /// How many tabs to show inline on tablets before overflowing into a menu.
  final int maxTabletItems;

  /// If true, mobile shows a compact bar with a menu sheet.
  final bool compactOnMobile;

  DeviceType _deviceTypeFor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = math.min(size.width, size.height);
    if (shortest >= 1200.sW) return DeviceType.desktop;
    if (shortest >= 768.sW) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = _deviceTypeFor(context);

    if (deviceType == DeviceType.mobile && compactOnMobile) {
      return _MobileTopBar(
        logoPath: logoPath,
        brand: brand,
        items: items,
        selectedIndex: selectedIndex,
        onItemTap: onItemTap,
        onLoginTap: onLoginTap,
        showScanButton: showScanButton,
        onScanTap: onScanTap,
      );
    }

    // Tablet/Desktop: wide pill with optional overflow on tablet
    return _WideTopBar(
      logoPath: logoPath,
      brand: brand,
      items: items,
      selectedIndex: selectedIndex,
      onItemTap: onItemTap,
      onLoginTap: onLoginTap,
      showScanButton: showScanButton,
      onScanTap: onScanTap,
      isTablet: deviceType == DeviceType.tablet,
      maxTabletItems: maxTabletItems,
    );
  }
}

/* ===========================
   Mobile (compact) variant
   =========================== */
class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({
    required this.logoPath,
    required this.brand,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onLoginTap,
    required this.showScanButton,
    required this.onScanTap,
  });

  final String logoPath;
  final String brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.h,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.gray400,
                  borderRadius: BorderRadius.circular(4.h),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                child: Row(
                  children: [
                    _Brand(logoPath: logoPath, brand: brand),
                    const Spacer(),
                    _LoginButton(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onLoginTap?.call();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...List.generate(items.length, (i) {
                final selected = i == selectedIndex;
                return ListTile(
                  title: Text(
                    items[i],
                    style: selected
                        ? TextStyleHelper.instance.title16BoldInter
                        : TextStyleHelper.instance.title16RegularInter,
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColor.gray900)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onItemTap?.call(i);
                  },
                );
              }),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 85.sH,
            padding: EdgeInsets.symmetric(horizontal: 12.sSp),
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.gray900, width: 1.sW),
              borderRadius: BorderRadius.circular(50.sH),
            ),
            child: Row(
              children: [
                _Brand(logoPath: logoPath, brand: brand),
                const Spacer(),
                // Selected tab label (context cue)
                if (items.isNotEmpty)
                  Text(
                    items[selectedIndex.clamp(0, items.length - 1)],
                    style: TextStyleHelper.instance.title16RegularInter,
                  ),
                SizedBox(width: 8.sSp),
                _MenuButton(onTap: () => _openMenu(context)),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.sSp),
        if (showScanButton) _ScanButton(onTap: onScanTap),
      ],
    );
  }
}

/* ===========================
   Tablet/Desktop (wide) variant
   =========================== */
class _WideTopBar extends StatelessWidget {
  const _WideTopBar({
    required this.logoPath,
    required this.brand,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onLoginTap,
    required this.showScanButton,
    required this.onScanTap,
    required this.isTablet,
    required this.maxTabletItems,
  });

  final String logoPath;
  final String brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final bool showScanButton;
  final VoidCallback? onScanTap;
  final bool isTablet;
  final int maxTabletItems;

  @override
  Widget build(BuildContext context) {
    final inlineItems = isTablet ? items.take(maxTabletItems).toList() : items;
    final overflowItems = isTablet && items.length > inlineItems.length
        ? items.sublist(inlineItems.length)
        : const <String>[];

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 72.sH,
            padding: EdgeInsets.all(16.sSp),
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.gray900, width: 1.sW),
              borderRadius: BorderRadius.circular(50.sH),
            ),
            child: Row(
              children: [
                _Brand(logoPath: logoPath, brand: brand),
                const Spacer(),
                Row(
                  children: [
                    for (int i = 0; i < inlineItems.length; i++) ...[
                      _NavText(
                        inlineItems[i],
                        selected:
                        items.indexOf(inlineItems[i]) == selectedIndex,
                        onTap: () =>
                            onItemTap?.call(items.indexOf(inlineItems[i])),
                      ),
                      SizedBox(width: 16.sSp),
                    ],
                    if (overflowItems.isNotEmpty)
                      _OverflowMenu(
                        labels: overflowItems,
                        onSelected: (label) =>
                            onItemTap?.call(items.indexOf(label)),
                      ),
                    SizedBox(width: 16.sSp),
                    _LoginButton(onTap: onLoginTap),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.sSp),
        if (showScanButton) _ScanButton(onTap: onScanTap),
      ],
    );
  }
}

/* ===========================
   Shared atoms
   =========================== */
class _Brand extends StatelessWidget {
  const _Brand({required this.logoPath, required this.brand});
  final String logoPath;
  final String brand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100.sH),
          child: Container(
            width: 50.sW,
            height: 50.sH,
            color: AppColor.grey200,
            child: Image.asset(logoPath, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 8.sSp),
        Text(brand, style: TextStyleHelper.instance.headline24BoldInter),
      ],
    );
  }
}

class _NavText extends StatelessWidget {
  const _NavText(this.label, {required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = selected
        ? TextStyleHelper.instance.title16BoldInter
        : TextStyleHelper.instance.title16RegularInter;
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 24.sH,
        decoration: selected
            ? BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColor.gray900, width: 2.sW),
          ),
        )
            : null,
        child: Text(label, style: style),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.sH),
      onTap: onTap,
      child: Container(
        height: 48.sH,
        padding: EdgeInsets.symmetric(horizontal: 24.sSp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.gray900,
          borderRadius: BorderRadius.circular(24.sH),
        ),
        child: Text(
          "Login",
          style: TextStyleHelper.instance.title16BoldInter.copyWith(
            color: AppColor.white,
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 40.sH,
        child: Container(
          width: 64.sW,
          height: 64.sH,
          decoration: BoxDecoration(
            color: AppColor.gray900,
            borderRadius: BorderRadius.circular(100.sH),
            border: Border.all(color: AppColor.gray900, width: 1.sW),
          ),
          child: const Center(
            child: Icon(Icons.qr_code_scanner, color: AppColor.white),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28.sH,
      child: Container(
        width: 40.sW,
        height: 40.sH,
        decoration: BoxDecoration(
          color: AppColor.gray900,
          borderRadius: BorderRadius.circular(100.sH),
        ),
        child: const Icon(Icons.menu, color: AppColor.white, size: 20),
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.labels, required this.onSelected});
  final List<String> labels;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: Offset(0, 24.sH),
      elevation: 2,
      itemBuilder: (context) => labels
          .map(
            (e) => PopupMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: TextStyleHelper.instance.title16RegularInter,
          ),
        ),
      )
          .toList(),
      child: Container(
        height: 32.sH,
        padding: EdgeInsets.symmetric(horizontal: 12.sSp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.blueGray100),
          borderRadius: BorderRadius.circular(16.sH),
        ),
        child: Row(
          children: [
            Text("More", style: TextStyleHelper.instance.title16RegularInter),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 18, color: AppColor.gray700),
          ],
        ),
      ),
    );
  }
}
