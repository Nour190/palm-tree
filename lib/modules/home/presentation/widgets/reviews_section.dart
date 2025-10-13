import 'dart:async';
import 'package:baseqat/modules/home/data/models/review_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';
import 'reviews/review_card_widget.dart';
import 'reviews/animated_carousel_item_widget.dart';
import 'reviews/bottom_bar_widget.dart';

class Reviews extends StatefulWidget {
  final List<ReviewModel> reviewsData;
  final bool isLoading;
  const Reviews({super.key, required this.reviewsData, this.isLoading = false});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  late PageController _pageController;
  int _currentIndex = 0;

  // autoplay
  Timer? _autoTimer;
  final Duration _autoInterval = const Duration(seconds: 5);
  bool _isUserInteracting = false;

  // desktop UX
  final FocusNode _focusNode = FocusNode(debugLabel: 'ReviewsFocus');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, keepPage: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoplay();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final desiredVF = Responsive.isDesktop(context) ? 0.34 : 0.9;
    if (_pageController.viewportFraction != desiredVF) {
      final oldIndex = _currentIndex;
      final old = _pageController;

      _pageController = PageController(
        viewportFraction: desiredVF,
        initialPage: oldIndex,
        keepPage: true,
      );

      setState(() {});
      old.dispose();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoInterval, (t) {
      if (!mounted || _isUserInteracting || widget.reviewsData.isEmpty) return;
      final next = (_currentIndex + 1) % widget.reviewsData.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pauseAutoplayTemporarily() {
    _isUserInteracting = true;
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _isUserInteracting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = _getHorizontalPadding(context);
    final vertical = _getVerticalPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    if (widget.reviewsData.isEmpty) {
      return Container(
        width: double.infinity,
        color: AppColor.gray900,
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child:Text(
          'home.reviews'.tr(),
          textAlign: TextAlign.left,
          style: TextStyleHelper.instance.headline28BoldInter.copyWith(
            color: AppColor.whiteCustom,
            height: 1.15,
          ),
     ),);
    }

    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: isDesktop,
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _PrevPageIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const _NextPageIntent(),
      },
      actions: <Type, Action<Intent>>{
        _PrevPageIntent: CallbackAction<_PrevPageIntent>(
          onInvoke: (_) {
            _goPrev();
            return null;
          },
        ),
        _NextPageIntent: CallbackAction<_NextPageIntent>(
          onInvoke: (_) {
            _goNext();
            return null;
          },
        ),
      },
      child: Container(
        width: double.infinity,
        color: AppColor.gray900,
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: _getSectionSpacing(context)),
              child: Text(
                'home.reviews'.tr(),
                textAlign: TextAlign.left,
                style: TextStyleHelper.instance.headline28BoldInter.copyWith(
                  color: AppColor.whiteCustom,
                  height: 1.15,
                ),
              ),
            ),
            if (widget.isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: 8.sH),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColor.primaryColor,
                ),
              ),
            SizedBox(
              height: _getContentHeight(context),
              child: Listener(
                onPointerDown: (_) => _pauseAutoplayTemporarily(),
                onPointerSignal: (_) => _pauseAutoplayTemporarily(),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemCount: widget.reviewsData.length,
                  itemBuilder: (context, index) {
                    return AnimatedCarouselItemWidget(
                      controller: _pageController,
                      index: index,
                      child: ReviewCardWidget(
                        review: widget.reviewsData[index],
                        desktop: isDesktop,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: _getIndicatorSpacing(context)),
            BottomBarWidget(
              length: widget.reviewsData.length,
              current: _currentIndex,
              onDotTap: (i) {
                _pauseAutoplayTemporarily();
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              onPrev: _goPrev,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }

  void _goPrev() {
    _pauseAutoplayTemporarily();
    final prev = _currentIndex - 1;
    _pageController.animateToPage(
      prev < 0 ? widget.reviewsData.length - 1 : prev,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    _pauseAutoplayTemporarily();
    final next = (_currentIndex + 1) % widget.reviewsData.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  double _getHorizontalPadding(BuildContext context) =>
      Responsive.isDesktop(context) ? 80.sW : 24.sW;

  double _getVerticalPadding(BuildContext context) =>
      Responsive.isDesktop(context) ? 80.sH : 40.sH;

  double _getSectionSpacing(BuildContext context) =>
      Responsive.isDesktop(context) ? 32.sH : 24.sH;

  double _getIndicatorSpacing(BuildContext context) =>
      Responsive.isDesktop(context) ? 28.sH : 22.sH;

  double _getContentHeight(BuildContext context) =>
      Responsive.isDesktop(context) ? 420.sH : 360.sH;
}

class _NextPageIntent extends Intent {
  const _NextPageIntent();
}

class _PrevPageIntent extends Intent {
  const _PrevPageIntent();
}
