import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';

class IthraReviewsSection extends StatelessWidget {
  final List<dynamic> reviews;
  final bool isLoading;

  const IthraReviewsSection({
    super.key,
    required this.reviews,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    return Container(
      width: double.infinity,
      color: AppColor.black,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 48.sW
            : isTablet
            ? 32.sW
            : 18.sW,
        vertical: isMobile ? 32.sH : 48.sH,
      ),
      child: Column(
        children: [
          // Section title
          Text(
            'home.reviews'.tr(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isDesktop
                  ? 32.sSp
                  : isTablet
                  ? 28.sSp
                  : 24.sSp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isMobile ? 24.sH : 32.sH),

          // Review content
          if (isLoading)
            _buildLoadingState(context, deviceType)
          else if (reviews.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildReviewCard(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;
    // Use the first review for display
    final review = reviews.first;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 600.sW : double.infinity,
      ),
      child: Column(
        children: [
          // Reviewer avatar
          Container(
            width: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
            height: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _buildReviewerImage(review),
            ),
          ),

          SizedBox(height: 20.sH),

          // Reviewer name
          Text(
            _getReviewerName(review),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 18.sSp : isTablet ? 20.sSp : 22.sSp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 16.sH),

          // Review text
          Text(
            _getReviewText(review),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 14.sSp : 16.sSp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),

          SizedBox(height: 20.sH),

          // Star rating
          _buildStarRating(context, _getReviewRating(review), deviceType),
        ],
      ),
    );
  }

  Widget _buildReviewerImage(dynamic review) {
    final String? imagePath = _getReviewerImagePath(review);

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return HomeImage(
          path: imagePath,
          fit: BoxFit.cover,
          errorChild: _buildFallbackReviewerImage(review),
        );
      } else {
        return CustomImageView(
          imagePath: imagePath,
          fit: BoxFit.cover,
        );
      }
    }

    return _buildFallbackReviewerImage(review);
  }

  Widget _buildFallbackReviewerImage(dynamic review) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getReviewerInitials(review),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(BuildContext context, double rating, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(
            Icons.star_rounded,
            size: isMobile ? 20.sW : 24.sW,
            color: Colors.amber,
          );
        } else if (index == fullStars && hasHalfStar) {
          return Icon(
            Icons.star_half_rounded,
            size: isMobile ? 20.sW : 24.sW,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            size: isMobile ? 20.sW : 24.sW,
            color: Colors.white.withOpacity(0.3),
          );
        }
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    return Column(
      children: [
        // Loading avatar
        Container(
          width: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
          height: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        ),

        SizedBox(height: 20.sH),

        // Loading name
        Container(
          width: 150.sW,
          height: 20.sH,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.sR),
          ),
        ),

        SizedBox(height: 16.sH),

        // Loading text
        Column(
          children: List.generate(3, (index) => Container(
            margin: EdgeInsets.only(bottom: 8.sH),
            width: double.infinity,
            height: 16.sH,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.sR),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Column(
      children: [
        Icon(
          Icons.rate_review_outlined,
          size: isMobile ? 48.sW : 64.sW,
          color: Colors.white.withOpacity(0.3),
        ),
        SizedBox(height: 16.sH),
        Text(
          'home.no_reviews_available'.tr(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 16.sSp : 18.sSp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Helper methods to extract data from review object
  String? _getReviewerImagePath(dynamic review) {
    if (review == null) return null;

    if (review is Map) {
      return review['userImage'] ??
          review['avatar'] ??
          review['profileImage'] ??
          review['image'];
    }

    try {
      return review.userImage ??
          review.avatar ??
          review.profileImage ??
          review.image;
    } catch (e) {
      return null;
    }
  }

  String _getReviewerName(dynamic review) {
    if (review == null) return 'Anonymous';

    if (review is Map) {
      return review['userName'] ??
          review['name'] ??
          review['reviewerName'] ??
          'Anonymous';
    }

    try {
      return review.userName ??
          review.name ??
          review.reviewerName ??
          'Anonymous';
    } catch (e) {
      return 'Anonymous';
    }
  }

  String _getReviewText(dynamic review) {
    if (review == null) return 'Great experience with the cultural center!';

    if (review is Map) {
      return review['review'] ??
          review['comment'] ??
          review['text'] ??
          review['content'] ??
          'Great experience with the cultural center!';
    }

    try {
      return review.review ??
          review.comment ??
          review.text ??
          review.content ??
          'Great experience with the cultural center!';
    } catch (e) {
      return 'Great experience with the cultural center!';
    }
  }

  double _getReviewRating(dynamic review) {
    if (review == null) return 5.0;

    if (review is Map) {
      final rating = review['rating'] ?? review['stars'] ?? 5.0;
      return (rating is num) ? rating.toDouble() : 5.0;
    }

    try {
      final rating = review.rating ?? review.stars ?? 5.0;
      return (rating is num) ? rating.toDouble() : 5.0;
    } catch (e) {
      return 5.0;
    }
  }

  String _getReviewerInitials(dynamic review) {
    final name = _getReviewerName(review);
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'A';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }
}
