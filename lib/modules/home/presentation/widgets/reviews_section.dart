import 'package:flutter/material.dart';
import 'common/app_section_header.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class Review {
  final String name;
  final String text;
  final String? avatarUrl;

  Review({required this.name, required this.text, this.avatarUrl});
}

class Reviews extends StatelessWidget {
  final bool isMobile, isTablet;

  /// Provide your own reviews; if null, a simple default is rendered.
  final List<Review>? reviews;

  const Reviews({
    super.key,
    required this.isMobile,
    required this.isTablet,
    this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final data =
        reviews ??
        [
          Review(
            name: 'Mohamed Hassan',
            text:
                'My experience on the website was amazing! The interface is easy to use and helped me quickly discover unique exhibitions and artworks.',
          ),
        ];

    return Container(
      width: double.infinity,
      color: AppColor.gray900,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified section header (white by default, so we override color via copyWith)
          AppSectionHeader(title: 'Reviews'),
          const SizedBox(height: 12),
          // Content centered inside dark background
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: data.map((r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _ReviewCard(review: r),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return Column(
      children: [
        _Avatar(name: review.name, url: review.avatarUrl, size: 96),
        const SizedBox(height: 8),
        Text(
          review.name,
          style: styles.headline24BoldInter.copyWith(
            color: AppColor.whiteCustom,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          review.text,
          style: styles.title16Inter.copyWith(color: AppColor.whiteCustom),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double size;

  const _Avatar({required this.name, this.url, this.size = 64});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
          ],
        ),
      );
    }

    // Fallback: colored initials
    final color = Colors.blueGrey.shade400;
    final initials = _initialsFromName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _initialsFromName(String n) {
    final parts = n
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
