import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/services/locale_service.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/utils/rtl_helper.dart';

class IthraWelcomeSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? titleAr;
  final String? subtitleAr;
  final String? highlightsLabel;
  final String? highlightsLabelAr;
  final List<String> images;

  const IthraWelcomeSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleAr,
    this.subtitleAr,
    this.highlightsLabel,
    this.highlightsLabelAr,
    required this.images,
  });

  @override
  State<IthraWelcomeSection> createState() => _IthraWelcomeSectionState();
}

class _IthraWelcomeSectionState extends State<IthraWelcomeSection> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  DeviceType get _deviceType => Responsive.deviceTypeOf(context);
  bool get _isMobile => _deviceType == DeviceType.mobile;
  bool get _isTablet => _deviceType == DeviceType.tablet;
  bool get _isDesktop => _deviceType == DeviceType.desktop;
  bool get _isRTL => LocaleService.isRTL(context.locale);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:  16.sW,
        vertical:  20.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeText(),
          SizedBox(height: 20.sH),
          _buildHeroCarousel(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return SizedBox(
      width: _isDesktop ? MediaQuery.of(context).size.width * 0.4 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(_getLocalizedText(widget.title, widget.titleAr), TextStyleHelper.instance.headline28MediumInter.copyWith(fontWeight: FontWeight.w900),maxLines:1 ),
          SizedBox(height: 8.sH),
          Padding(
            padding:_isTablet? RTLHelper.getDirectionalPadding(end: 60.sW): EdgeInsets.all(0),
            child: _buildText(_getLocalizedText(widget.subtitle, widget.subtitleAr), TextStyleHelper.instance.title16RegularInter, maxLines: _isTablet?3:5),
          ),
          SizedBox(height: 20.sH),
          _buildText(_getHighlightsLabel(), TextStyleHelper.instance.title16BoldInter),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    if (widget.images.isEmpty) return _buildPlaceholder();

    final height = _isMobile ? 280.sH : _isTablet ? 450.sH : 600.sH;

    return Column(
      children: [
        _buildCarouselContainer(height),
        if (widget.images.length > 1) ...[
          SizedBox(height: 16.sH),
          _buildCarouselIndicators(),
        ],
      ],
    );
  }

  Widget _buildCarouselContainer(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.sR),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sR),
        child: CarouselSlider(
          carouselController: _carouselController,
          options: _carouselOptions(height),
          items: widget.images.map((path) => _buildCarouselItem(path)).toList(),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath) {
    return Stack(
      children: [
        Positioned.fill(child: HomeImage(path: imagePath, fit: BoxFit.cover, errorChild: _buildPlaceholder())),
        Positioned.fill(child: _buildGradientOverlay()),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColor.black.withOpacity(0.3)],
          stops: const [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length.clamp(0, 5),
        (index) => GestureDetector(
          onTap: () => _carouselController.animateToPage(index, duration: const Duration(milliseconds: 600),),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            margin: EdgeInsets.symmetric(horizontal: 4.sW),
            width: index == _currentIndex ? 24.sW : 8.sW,
            height: 8.sH,
            decoration: BoxDecoration(
              color: index == _currentIndex ? AppColor.black : AppColor.gray400,
              borderRadius: BorderRadius.circular(4.sR),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F5F5), Color(0xFFE5E7EB)],
        ),
        borderRadius: BorderRadius.circular(16.sR),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: _isMobile ? 48.sW : 64.sW, color: AppColor.gray400),
            SizedBox(height: 8.sH),
            Text(
              'Welcome to the palm tree',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: _isMobile ? 16.sSp : 18.sSp,
                fontWeight: FontWeight.w500,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text, TextStyle style, {int? maxLines}) {
    return Text(text, style: style, maxLines: maxLines, overflow: maxLines != null ? TextOverflow.ellipsis : null);
  }

  CarouselOptions _carouselOptions(double height) {
    return CarouselOptions(
      height: height,
      viewportFraction: 1.0,
      initialPage: 0,
      enableInfiniteScroll: widget.images.length > 1,
      reverse: false,
      autoPlay: widget.images.length > 1,
      autoPlayInterval: const Duration(seconds: 4),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: false,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index, _) => setState(() => _currentIndex = index),
    );
  }

  // TextStyle get _titleStyle => TextStyle(
  //   fontFamily: 'Inter',
  //   fontSize:
  //   fontWeight: FontWeight.w700,
  //   color: AppColor.black,
  //   height: 1.2,
  //   letterSpacing: -0.5,
  // );

  TextStyle get _subtitleStyle => TextStyle(
    fontFamily: 'Inter',
    fontSize: _isDesktop ? 16.sSp : _isTablet ? 15.sSp : 14.sSp,
    fontWeight: FontWeight.w400,
    color: AppColor.gray600,
    height: 1.5,
  );

  TextStyle get _highlightsStyle => TextStyle(
    fontFamily: 'Inter',
    fontSize: _isDesktop ? 18.sSp : _isTablet ? 16.sSp : 15.sSp,
    fontWeight: FontWeight.w600,
    color: AppColor.black,
  );

  String _getLocalizedText(String en, String? ar) {
    final arText = (ar ?? '').trim();
    return _isRTL && arText.isNotEmpty ? arText : en.trim();
  }

  String _getHighlightsLabel() => _getLocalizedText(
    widget.highlightsLabel ?? 'Highlights',
    widget.highlightsLabelAr ?? 'المختارات',
  );
}