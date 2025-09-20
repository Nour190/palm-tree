// reviews.dart
import 'dart:async';
import 'package:baseqat/modules/home/data/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

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

  /// This is the right place to read MediaQuery/Responsive.
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

      setState(() {}); // rebuild so PageView picks the new controller
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

    // Empty-state guard
    if (widget.reviewsData.isEmpty) {
      return Container(
        width: double.infinity,
        color: AppColor.gray900,
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: _HeaderRow(isDesktop: isDesktop),
      );
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
              child: _HeaderRow(isDesktop: isDesktop),
            ),
            if (widget.isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: 8.sH),
                child:  LinearProgressIndicator(minHeight: 2,color: AppColor.primaryColor,),
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
                    return _AnimatedCarouselItem(
                      controller: _pageController,
                      index: index,
                      child: _ReviewCard(
                        review: widget.reviewsData[index],
                        desktop: isDesktop,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: _getIndicatorSpacing(context)),
            _BottomBar(
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

/// Intents for keyboard navigation
class _NextPageIntent extends Intent {
  const _NextPageIntent();
}

class _PrevPageIntent extends Intent {
  const _PrevPageIntent();
}

/// Header row (title + swipe hint / arrows on desktop)
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.isDesktop});
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            // Consider localizing this
            'What people are saying',
            textAlign: TextAlign.left,
            style:
                (styles.headline20BoldInter)
                    .copyWith(color: AppColor.whiteCustom, height: 1.15),
          ),
        ),
        if (!isDesktop)
          Text(
            'Swipe',
            style: (styles.body14RegularInter).copyWith(
              color: AppColor.gray400,
              height: 1.2,
            ),
          ),
      ],
    );
  }
}

/// Bottom bar shows indicators on all devices and arrow buttons on desktop.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.length,
    required this.current,
    required this.onDotTap,
    required this.onPrev,
    required this.onNext,
  });

  final int length;
  final int current;
  final ValueChanged<int> onDotTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isDesktop)
          _ArrowButton(icon: Icons.chevron_left, onPressed: onPrev),
        SizedBox(width: isDesktop ? 16.sW : 0),
        _Dots(length: length, current: current, onTap: onDotTap),
        SizedBox(width: isDesktop ? 16.sW : 0),
        if (isDesktop)
          _ArrowButton(icon: Icons.chevron_right, onPressed: onNext),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = icon == Icons.chevron_left
        ? 'Previous review'
        : 'Next review';
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColor.gray700,
        borderRadius: BorderRadius.circular(12.sH),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.sH),
          child: Padding(
            padding: EdgeInsets.all(8.sH),
            child: Icon(icon, color: AppColor.whiteCustom, size: 28.sSp),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.length,
    required this.current,
    required this.onTap,
  });

  final int length;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.sW,
      children: List.generate(length, (i) {
        final bool active = current == i;
        final double w = active
            ? (Responsive.isDesktop(context) ? 28.sW : 22.sW)
            : 8.sW;
        return Semantics(
          button: true,
          label: 'Go to review ${i + 1}',
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 8.sH,
              width: w,
              decoration: BoxDecoration(
                color: active ? AppColor.whiteCustom : AppColor.gray600,
                borderRadius: BorderRadius.circular(4.sH),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Animated wrapper that scales/fades items based on their distance to the current page.
class _AnimatedCarouselItem extends StatelessWidget {
  const _AnimatedCarouselItem({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double t = 0;
        if (controller.position.haveDimensions) {
          final page = controller.page ?? controller.initialPage.toDouble();
          t = page - index;
        }
        // Closer to 0 => current page
        final scale = (1 - (t.abs() * 0.08)).clamp(0.9, 1.0);
        final opacity = (1 - (t.abs() * 0.35)).clamp(0.55, 1.0);

        return RepaintBoundary(
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
    );
  }
}

/// === CARDS ===================================================================

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.review, required this.desktop});

  final ReviewModel review;
  final bool desktop;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final desktop = widget.desktop;
    final review = widget.review;

    final cardPadding = desktop ? EdgeInsets.all(24.sH) : EdgeInsets.all(18.sH);
    final radius = BorderRadius.circular(20.sH);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(
          horizontal: desktop ? 12.sW : 8.sW,
          vertical: desktop ? 8.sH : 4.sH,
        ),
        decoration: BoxDecoration(
          color: _cardBgColor(context),
          borderRadius: radius,
          border: Border.all(
            color: AppColor.gray700.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.25 : 0.18),
              blurRadius: _hovered ? 28.sH : 18.sH,
              offset: Offset(0, _hovered ? 16.sH : 10.sH),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.gray700.withOpacity(0.85),
              AppColor.gray900.withOpacity(0.85),
            ],
          ),
        ),
        child: Padding(
          padding: cardPadding,
          child: desktop
              ? _DesktopLayout(review: review)
              : _MobileTabletLayout(review: review),
        ),
      ),
    );
  }

  Color _cardBgColor(BuildContext context) {
    return AppColor.gray700.withOpacity(0.65);
  }
}

/// Mobile/Tablet layout: stacked avatar -> name -> stars -> text
class _MobileTabletLayout extends StatelessWidget {
  const _MobileTabletLayout({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ReviewAvatar(
          name: review.name,
          gender: review.gender,
          avatarUrl: review.avatarUrl,
        ),
        SizedBox(height: 14.sH),
        _ReviewerName(name: review.name),
        SizedBox(height: 10.sH),
        _RatingStars(rating: review.rating),
        SizedBox(height: 16.sH),
        _QuoteText(text: review.textEn, maxLines: 5),
      ],
    );
  }
}

/// Desktop layout: avatar + name/stars row, then quote to the right
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 80.sH;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ReviewAvatar(
          name: review.name,
          gender: review.gender,
          avatarUrl: review.avatarUrl,
        ),
        SizedBox(height: 14.sH),
        _ReviewerName(name: review.name),
        SizedBox(height: 10.sH),
        _RatingStars(rating: review.rating),
        SizedBox(height: 16.sH),
        _QuoteText(text: review.textEn, maxLines: 5),
      ],
    );
    //   Row(
    //   children: [
    //     _ReviewAvatar(
    //       name: review.name,
    //       gender: review.gender,
    //       avatarUrl: review.avatarUrl,
    //       overrideSize: avatarSize,
    //     ),
    //     SizedBox(width: 18.sW),
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Wrap(
    //             crossAxisAlignment: WrapCrossAlignment.center,
    //             spacing: 10.sW,
    //             runSpacing: 6.sH,
    //             children: [
    //               _ReviewerName(name: review.name, alignLeft: true),
    //               _RatingStars(rating: review.rating),
    //             ],
    //           ),
    //           SizedBox(height: 12.sH),
    //           _QuoteText(text: review.textEn, alignLeft: true, maxLines: 4),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({
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
     // border: Border.all(
     //   color: Colors.white,
     //   //width: Responsive.isDesktop(context) ? 1.sW : 1.sW,
     // ),
     boxShadow: [
       BoxShadow(
         color: Colors.black.withOpacity(0.3),
         blurRadius: 20.sH,
         offset: Offset(0, 10.sH),
       ),
     ],
   ),
   child: ClipOval(
     child: Image.network(
       avatarUrl,
       fit: BoxFit.cover,
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
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: Responsive.isDesktop(context) ? 36.sSp : 28.sSp,
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

class _ReviewerName extends StatelessWidget {
  const _ReviewerName({required this.name, this.alignLeft = false});

  final String name;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final desktop = Responsive.isDesktop(context);

    final style =
      styles.title18BoldInter;

    return Text(
      name,
      textAlign: alignLeft ? TextAlign.left : TextAlign.center,
      style: style.copyWith(color: AppColor.whiteCustom, height: 1.15),
    );
  }
}

class _QuoteText extends StatelessWidget {
  const _QuoteText({
    required this.text,
    this.alignLeft = false,
    this.maxLines = 4,
  });

  final String text;
  final bool alignLeft;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final desktop = Responsive.isDesktop(context);

    final base = styles.body14MediumInter;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quotation accent
        Padding(
          padding: EdgeInsets.only(top: 2.sH, right: 8.sW),
          child: Icon(
            Icons.format_quote,
            size: 20.sSp,
            color: AppColor.gray200,
          ),
        ),
        Expanded(
          child: Text(
            text,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: base.copyWith(
              color: AppColor.gray200,
              height: desktop ? 1.5 : 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final frac = rating - full;
    final hasHalf = frac >= 0.25 && frac < 0.75;
    const total = 5;

    final stars = List<Widget>.generate(total, (i) {
      IconData icon;
      if (i < full) {
        icon = Icons.star;
      } else if (i == full && hasHalf) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, size: 18.sSp, color: Colors.amber);
    });

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
