// lib/modules/home/presentation/widgets/about_info.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:baseqat/core/services/locale_service.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'common/custom_image_view.dart';

class AboutInfo extends StatefulWidget {
  final InfoModel info;
  final DeviceType? deviceTypeOverride;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AboutInfo({
    super.key,
    required this.info,
    this.deviceTypeOverride,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<AboutInfo> createState() => _AboutInfoState();
}

class _AboutInfoState extends State<AboutInfo> {
  DeviceType get _deviceType => widget.deviceTypeOverride ?? Responsive.deviceTypeOf(context);
  bool get _isMobile => _deviceType == DeviceType.mobile;
  bool get _isTablet => _deviceType == DeviceType.tablet;
  bool get _isDesktop => _deviceType == DeviceType.desktop;
  bool get _isRTL => LocaleService.isRTL(context.locale);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 48.sW : _isTablet ? 32.sW : 18.sW,
        vertical: _isMobile ? 32.sH : 48.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildHeader(),
          // SizedBox(height: _isMobile ? 24.sH : 32.sH),
          _buildSection(_SectionConfig.about(widget.info, _isRTL)),
          SizedBox(height: _isMobile ? 32.sH : 48.sH),
          _buildSection(_SectionConfig.vision(widget.info, _isRTL)),
          SizedBox(height: _isMobile ? 32.sH : 48.sH),
          _buildSection(_SectionConfig.mission(widget.info, _isRTL)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final mainTitle = _getLocalizedTitle(widget.info.mainTitle, widget.info.mainTitleAr);
    final subTitle = _normalizeText(_getLocalizedTitle(widget.info.subTitle, widget.info.subTitleAr));
    final heroImage = widget.info.bannerImages?.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mainTitle.isNotEmpty) ...[
          _buildText(mainTitle, _titleStyle(_isDesktop ? 28 : _isTablet ? 26 : 24, FontWeight.w800)),
          SizedBox(height: 8.sH),
        ],
        if (subTitle.isNotEmpty) ...[
          _buildText(subTitle, _bodyStyle(_isDesktop ? 16 : _isTablet ? 15 : 14, FontWeight.w500)),
          SizedBox(height: 16.sH),
        ],
        if (heroImage != null) _buildImage(heroImage, _isMobile ? 200.sH : _isTablet ? 260.sH : 300.sH),
      ],
    );
  }

  Widget _buildSection(_SectionConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.showTitleFirst) ...[
          _buildText(config.title, _titleStyle(_isDesktop ? 24 : _isTablet ? 22 : 20, FontWeight.w700)),
          SizedBox(height: 24.sH),
        ],
        _isMobile ? _buildMobileLayout(config) : _buildDesktopLayout(config),
      ],
    );
  }

  Widget _buildMobileLayout(_SectionConfig config) {
    if (config.type == _SectionType.about) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.images.isNotEmpty) _buildImage(config.images[0], 200.sH),
          if (config.images.length > 1) ...[SizedBox(height: 12.sH), _buildImage(config.images[1], 200.sH)],
          SizedBox(height: 20.sH),
          _buildText(config.text, _bodyStyle(14)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.images.isNotEmpty) _buildImage(config.images[0], 250.sH),
        SizedBox(height: config.type == _SectionType.vision ? 20.sH : 12.sH),
        _buildText(config.title, _titleStyle(20, FontWeight.w700)),
        SizedBox(height: config.type == _SectionType.vision ? 12.sH : 20.sH),
        _buildText(config.text, _bodyStyle(14)),
      ],
    );
  }

  Widget _buildDesktopLayout(_SectionConfig config) {
    if (config.type == _SectionType.about) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.images.isNotEmpty) Expanded(flex: 3, child: _buildImage(config.images[0], _isTablet ? 220.sH : 240.sH)),
              if (config.images.length > 1) ...[
                SizedBox(width: 12.sW),
                Expanded(flex: 2, child: _buildImage(config.images[1], _isTablet ? 180.sH : 220.sH)),
              ],
            ],
          ),
          SizedBox(height: 24.sH),
          _buildText(config.text, _bodyStyle(_isTablet ? 15 : 16)),
        ],
      );
    }

    final imageHeight = _isTablet ? 280.sH : 320.sH;
    final content = Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(config.title, _titleStyle(_isTablet ? 28 : 32, FontWeight.w700)),
          SizedBox(height: 16.sH),
          _buildText(config.text, _bodyStyle(_isTablet ? 15 : 16)),
        ],
      ),
    );
    final image = Expanded(
      flex: 2,
      child: config.images.isNotEmpty ? _buildImage(config.images[0], imageHeight) : _buildPlaceholder(imageHeight),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: config.type == _SectionType.vision 
        ? [image, SizedBox(width: 32.sW), content]
        : [content, SizedBox(width: 32.sW), image],
    );
  }

  Widget _buildImage(String url, double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.sR), color: AppColor.gray100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sR),
        child: widget.isLoading ? _buildPlaceholderIcon() : CustomImageView(imagePath: url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(color: AppColor.gray100, borderRadius: BorderRadius.circular(16.sR)),
      child: _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() => Center(child: Icon(Icons.image_outlined, size: 48.sW, color: AppColor.gray400));

  Widget _buildText(String text, TextStyle style) {
    return Text(text, style: style, textDirection: _isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr);
  }

  TextStyle _titleStyle(double size, FontWeight weight) => TextStyle(
    fontFamily: 'Inter', fontSize: size.sSp, fontWeight: weight, color: AppColor.black, height: 1.15,
  );

  TextStyle _bodyStyle(double size, [FontWeight weight = FontWeight.w400]) => TextStyle(
    fontFamily: 'Inter', fontSize: size.sSp, fontWeight: weight, color: AppColor.gray700, height: 1.6,
  );

  String _getLocalizedTitle(String? en, String? ar) {
    final enText = (en ?? '').trim();
    final arText = (ar ?? '').trim();
    return _isRTL && arText.isNotEmpty ? arText : enText;
  }

  String _normalizeText(String text) => text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

enum _SectionType { about, vision, mission }

class _SectionConfig {
  final _SectionType type;
  final String title;
  final String text;
  final List<String> images;
  final bool showTitleFirst;

  _SectionConfig({
    required this.type,
    required this.title,
    required this.text,
    required this.images,
    this.showTitleFirst = false,
  });

  factory _SectionConfig.about(InfoModel info, bool isRTL) => _SectionConfig(
    type: _SectionType.about,
    title: isRTL ? 'حول' : 'About',
    text: info.localizedAbout(isRTL: isRTL) ?? (isRTL ? _Fallbacks.aboutAr : _Fallbacks.aboutEn),
    images: [...?info.aboutImages, AppAssetsManager.imgRectangle21],
    showTitleFirst: true,
  );

  factory _SectionConfig.vision(InfoModel info, bool isRTL) => _SectionConfig(
    type: _SectionType.vision,
    title: isRTL ? 'الرؤية' : 'Vision',
    text: info.localizedVision(isRTL: isRTL) ?? (isRTL ? _Fallbacks.visionAr : _Fallbacks.visionEn),
    images: info.visionImages ?? [],
  );

  factory _SectionConfig.mission(InfoModel info, bool isRTL) => _SectionConfig(
    type: _SectionType.mission,
    title: isRTL ? 'الرسالة' : 'Mission',
    text: info.localizedMission(isRTL: isRTL) ?? (isRTL ? _Fallbacks.missionAr : _Fallbacks.missionEn),
    images: info.missionImages ?? [],
  );
}

class _Fallbacks {
  static const aboutEn = 'The King Abdulaziz Center for World Culture (Ithra), meaning "enrichment" in Arabic, was built as part of Saudi Aramco\'s vision to be an ambitious initiative for the public. Ithra is the Kingdom\'s leading cultural and creative destination for talent development and cross-cultural experiences. Since its opening in 2018, each attraction by Ithra serves as a window to global experiences, celebrating human potential and empowering creativity. The pillars include culture, creativity, community, art, and knowledge. With the visionary platforms and key pillars, Ithra continuously offers inspiring workshops, performances, and events.';
  static const aboutAr = 'مركز الملك عبدالعزيز الثقافي العالمي (إثراء) — أي «الإثراء» — أُنشئ ضمن رؤية أرامكو السعودية ليكون مبادرة طموحة موجهة للجمهور. يُعد إثراء وجهة المملكة الرائدة للإبداع والثقافة وتطوير المواهب والتجارب العابرة للثقافات. منذ افتتاحه في 2018، تشكّل برامجه نافذة على الخبرات العالمية، تحتفي بالطاقة الإنسانية وتمكّن الإبداع. ترتكز رسالته على الثقافة والإبداع والمجتمع والفن والمعرفة، ويواصل تقديم ورش عمل وعروض وفعاليات ملهمة.';
  static const visionEn = 'At Ithra, we envision a future in which Saudi Arabia is a beacon for knowledge and creativity.';
  static const visionAr = 'في إثراء، نتطلع إلى مستقبل تكون فيه المملكة منارةً للمعرفة والإبداع.';
  static const missionEn = 'Ithra aims to make a tangible and positive impact on human development by inspiring a passion for knowledge, creativity and cross-cultural engagement for the future of the Kingdom.';
  static const missionAr = 'يهدف إثراء إلى تحقيق أثر ملموس وإيجابي في تنمية الإنسان عبر إلهام الشغف بالمعرفة والإبداع والتفاعل بين الثقافات لمستقبل المملكة.';
}