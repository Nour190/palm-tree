import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/services/locale_service.dart';
 import 'dart:ui' as ui;

import '../../responsive/responsive.dart';
import '../../utils/rtl_helper.dart';

class IthraMenuScreen extends StatefulWidget {
  const IthraMenuScreen({
    super.key,
    required this.logoPath,
    required this.brand,
    required this.items,
    required this.selectedIndex,
    this.onItemTap,
    this.onLoginTap,
    this.onScanTap,
  });

  final String logoPath;
  final String brand;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onScanTap;

  @override
  State<IthraMenuScreen> createState() => _IthraMenuScreenState();
}

class _IthraMenuScreenState extends State<IthraMenuScreen> {
  bool _isLanguageExpanded = false;


  final List<Map<String, dynamic>> _languages = [
    {'name': 'language.Arabic'.tr(), 'code': 'ar', 'locale': const Locale('ar', 'SA'), 'flag': '🇸🇦'},
    {'name': 'language.English'.tr(), 'code': 'en', 'locale': const Locale('en', 'US'), 'flag': '🇬🇧'},
    {'name': 'language.Germany'.tr(), 'code': 'de', 'locale': const Locale('de', 'DE'), 'flag': '🇩🇪'},
  ];

  Future<void> _changeLanguage(Map<String, dynamic> language) async {
    await LocaleService.changeLocale(context, language['locale']);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final devType = Responsive.deviceTypeOf(context);
    final isRTL = LocaleService.isRTL(context.locale);
    final currentLang = _languages.firstWhere(
      (lang) => lang['code'] == context.locale.languageCode,
      orElse: () => _languages[0],
    );

    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(AppAssetsManager.background),
              fit: BoxFit.contain,
             // opacity: 0.03,
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 80.sH,
                  padding: EdgeInsets.symmetric( horizontal: 12.sSp),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.sW,
                            height: 40.sH,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.sH),
                            ),
                            child: Image.asset(
                              widget.logoPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 12.sSp),
                          Text(
                            widget.brand,
                            style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (widget.onScanTap != null)
                            GestureDetector(
                              onTap: widget.onScanTap,
                              child: Container(
                                width: 48.sW,
                                height: 48.sH,
                                margin: RTLHelper.getDirectionalPadding(end: 12.sSp),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 48.sW,
                              height: 48.sH,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal:devType == DeviceType.tablet ? 16.sH: 14.sH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     //   SizedBox(height: 40.sH),

                        // Menu items
                        ...widget.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding:  EdgeInsets.symmetric(horizontal: 8.sW),
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onItemTap?.call(index);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical:devType == DeviceType.tablet ?20.sH: 8.sH),
                                    child: Text(
                                      item,
                                      style: TextStyleHelper.instance.headline32BoldInter.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 28.sSp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 2,
                                color: Colors.black87,
                                margin: EdgeInsets.only(bottom: 16.sH),
                              ),
                            ],
                          );
                        }).toList(),

                        //SizedBox(height: 20.sH),

                        // Language section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.sW),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLanguageExpanded = !_isLanguageExpanded;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical:devType == DeviceType.tablet ?14.sH: 4.sW),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'common.select_language'.tr(),
                                    style: TextStyleHelper.instance.headline32BoldInter.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 28.sSp,
                                    ),
                                  ),
                                  Icon(
                                    _isLanguageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (_isLanguageExpanded)
                          Padding(
                            padding: EdgeInsets.only(left: 20.sSp),
                            child: Column(
                              children: _languages.map((language) {
                                final isSelected = language['code'] == currentLang['code'];
                                return GestureDetector(
                                  onTap: () => _changeLanguage(language),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8.sH),
                                    child: Row(
                                      children: [
                                        Text(
                                          language['flag']!,
                                          style: TextStyle(fontSize: 32.sSp),
                                        ),
                                        SizedBox(width: 14.sH),
                                        Expanded(
                                          child: Text(
                                            language['name']!,
                                            style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                                              color: Colors.black,
                                              fontSize: 20.sSp,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 28.sW,
                                          height: 28.sH,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            color: isSelected ? Colors.black : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.circle,
                                                  color: Colors.white,
                                                  size: 16.sSp,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        Container(
                          height: 2,
                          color: Colors.black87,
                          margin: EdgeInsets.symmetric(vertical: 16.sSp),
                        ),

                        // SizedBox(height: 40.sH),
                        //
                        // // Login button
                        // BlocBuilder<AuthCubit, AuthState>(
                        //   builder: (context, state) {
                        //     final isAuthenticated = state is AuthAuthenticated;
                        //
                        //     if (!isAuthenticated) {
                        //       return Container(
                        //         width: double.infinity,
                        //         margin: EdgeInsets.only(bottom: 40.sH),
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             widget.onLoginTap?.call();
                        //             Navigator.of(context).pop();
                        //           },
                        //           child: Container(
                        //             height: 80.sH,
                        //             decoration: const BoxDecoration(
                        //               color: Colors.black,
                        //             ),
                        //             child: Center(
                        //               child: Text(
                        //                 'Login',
                        //                 style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.w600,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     } else {
                        //       return const SizedBox.shrink();
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

