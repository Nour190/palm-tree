import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/review_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/responsive/responsive.dart';
import 'review_avatar_widget.dart';
import 'reviewer_name_widget.dart';
import 'rating_stars_widget.dart';
import 'quote_text_widget.dart';

class ReviewCardWidget extends StatefulWidget {
  const ReviewCardWidget({
    super.key,
    required this.review,
    required this.desktop,
  });

  final ReviewModel review;
  final bool desktop;

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
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
        // decoration: BoxDecoration(
        //   color: _cardBgColor(context),
        //   borderRadius: radius,
        //   border: Border.all(
        //     color: AppColor.gray700.withOpacity(0.6),
        //     width: 1,
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: AppColor.black.withOpacity(_hovered ? 0.25 : 0.18),
        //       blurRadius: _hovered ? 28.sH : 18.sH,
        //       offset: Offset(0, _hovered ? 16.sH : 10.sH),
        //     ),
        //   ],
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       AppColor.gray700.withOpacity(0.85),
        //       AppColor.gray900.withOpacity(0.85),
        //     ],
        //   ),
        // ),
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

class _MobileTabletLayout extends StatelessWidget {
  const _MobileTabletLayout({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final text = _localizedReviewText(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReviewAvatarWidget(
          name: review.name,
          gender: review.gender,
          avatarUrl: review.avatarUrl,
        ),
        SizedBox(height: 14.sH),
        ReviewerNameWidget(name: review.name),
        SizedBox(height: 10.sH),
        RatingStarsWidget(rating: review.rating),
        SizedBox(height: Responsive.isTablet(context)? 0.sH:16.sH),
        Padding(
          padding: Responsive.isTablet(context)? EdgeInsets.symmetric(vertical: 30.sW):EdgeInsets.all(0),
          child:QuoteTextWidget(text: text, maxLines: 5),
        ),
      ],
    );
  }
  String _localizedReviewText(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final ar = review.textAr.trim();
    final en = review.textEn.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) {
      return ar;
    }
    return en.isNotEmpty ? en : ar;
  }
}

class _DesktopLayout extends StatelessWidget {
   _DesktopLayout({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final text = _localizedReviewText(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReviewAvatarWidget(
          name: review.name,
          gender: review.gender,
          avatarUrl: review.avatarUrl,
        ),
        SizedBox(height: 14.sH),
        ReviewerNameWidget(name: review.name),
        SizedBox(height: 10.sH),
        RatingStarsWidget(rating: review.rating),
        SizedBox(height: 16.sH),
        QuoteTextWidget(text: text, maxLines: 5),
      ],
    );
  }
  String _localizedReviewText(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final ar = review.textAr.trim();
    final en = review.textEn.trim();
    if (languageCode == 'ar' && ar.isNotEmpty) {
      return ar;
    }
    return en.isNotEmpty ? en : ar;
  }
}
