import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final bool isGridView;

  const ArtistCardWidget({
    super.key,
    required this.artist,
    this.onTap,
    this.isGridView = false,
  });

  bool get _useSmallChips => true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cityCountry = _getCityCountry(artist.city, artist.country);

    return Semantics(
      button: onTap != null,
      label: 'Artist card: ${artist.name}',
      child: Container(
        margin: EdgeInsets.all(isMobile ? 6.h : 8.h),
        decoration: _cardDecoration(isDark, isMobile),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(isMobile ? 16.h : 20.h),
            child: isGridView
                ? _gridLayout(context, isDark, isMobile, cityCountry)
                : _listLayout(context, isDark, isMobile, cityCountry),
          ),
        ),
      ),
    );
  }

  // ---- Layouts ----

  Widget _listLayout(
    BuildContext context,
    bool isDark,
    bool isMobile,
    String cityCountry,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12.h : 16.h),
      child: Row(
        children: [
          _profileImage(isMobile, isHorizontal: true),
          SizedBox(width: isMobile ? 12.h : 16.h),
          Expanded(child: _infoSection(isDark, isMobile, cityCountry)),
          if (!isMobile) _actionButton(isDark, isMobile),
        ],
      ),
    );
  }

  Widget _gridLayout(
    BuildContext context,
    bool isDark,
    bool isMobile,
    String cityCountry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileImage(isMobile, isHorizontal: false),
        Padding(
          padding: EdgeInsets.all(isMobile ? 12.h : 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoSection(
                isDark,
                isMobile,
                cityCountry,
                showLocationChip: true,
              ),
              if (isMobile) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(isDark, isMobile),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---- Pieces ----

  BoxDecoration _cardDecoration(bool isDark, bool isMobile) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(isMobile ? 16.h : 20.h),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.06),
        width: 1.h,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.30)
              : Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _profileImage(bool isMobile, {required bool isHorizontal}) {
    final imageWidth = isHorizontal
        ? (isMobile ? 64.h : 84.h)
        : double.infinity;
    final imageHeight = isHorizontal
        ? (isMobile ? 64.h : 84.h)
        : (isMobile ? 140.h : 180.h);

    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 12.h : 16.h),
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _NetImage(
              url: artist.profileImage,
              width: imageWidth,
              height: imageHeight,
            ),
            if (!isHorizontal)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 64.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.28),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(
    bool isDark,
    bool isMobile,
    String cityCountry, {
    bool showLocationChip = false,
  }) {
    final nameColor = isDark ? Colors.white : AppColor.gray900;
    final bodyColor = (isDark ? Colors.white : AppColor.gray700).withOpacity(
      0.85,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + optional location chip (for list view)
        Row(
          children: [
            Expanded(
              child: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.title16BoldInter.copyWith(
                  fontSize: isMobile ? 16.fSize : 18.fSize,
                  color: nameColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!isGridView && cityCountry.isNotEmpty)
              _Chip(
                text: cityCountry,
                color: _chipColors.location(isDark).fg,
                bg: _chipColors.location(isDark).bg,
                icon: Icons.location_on_rounded,
                isMobile: isMobile,
              ),
          ],
        ),
        SizedBox(height: 6.h),
        // About
        if ((artist.about ?? '').isNotEmpty)
          Text(
            artist.about!,
            maxLines: isGridView ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title16RegularInter.copyWith(
              fontSize: isMobile ? 12.fSize : 13.fSize,
              color: bodyColor,
              height: 1.45,
            ),
          ),
      ],
    );
  }

  Widget _actionButton(bool isDark, bool isMobile) {
    final size = isMobile ? 36.h : 40.h;
    return Padding(
      padding: EdgeInsets.only(left: 8.h),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.10) : AppColor.gray100,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.18) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: isMobile ? 18.h : 20.h,
          color: isDark ? Colors.white.withOpacity(0.85) : AppColor.gray700,
        ),
      ),
    );
  }

  // ---- helpers ----

  String _getCityCountry(String? city, String? country) {
    final c1 = (city ?? '').trim();
    final c2 = (country ?? '').trim();
    if (c1.isEmpty && c2.isEmpty) return '';
    if (c1.isEmpty) return c2;
    if (c2.isEmpty) return c1;
    return '$c1, $c2';
  }
}

// --------- Simple network image (no animations) ---------

class _NetImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const _NetImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();

    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _placeholder(),
            Center(
              child: SizedBox(
                width: (width * 0.18).clamp(16.0, 24.0),
                height: (width * 0.18).clamp(16.0, 24.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: Colors.grey.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[200]!, Colors.grey[100]!],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: (width * 0.4).clamp(20.0, 40.0),
        color: Colors.grey[400],
      ),
    );
  }
}

// --------- Chips & badges (static) ---------

class _chipColors {
  final Color fg;
  final Color bg;
  const _chipColors(this.fg, this.bg);

  static _chipColors location(bool dark) => dark
      ? _chipColors(Colors.blue[300]!, Colors.blue.withOpacity(0.18))
      : _chipColors(Colors.blue[700]!, Colors.blue.withOpacity(0.10));

  static _chipColors platform(bool dark) => dark
      ? _chipColors(Colors.purple[300]!, Colors.purple.withOpacity(0.18))
      : _chipColors(Colors.purple[700]!, Colors.purple.withOpacity(0.10));
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  final IconData? icon;
  final bool isMobile;

  const _Chip({
    required this.text,
    required this.color,
    required this.bg,
    this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6.h : 8.h,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: color.withOpacity(0.30), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isMobile ? 10.h : 12.h, color: color),
            SizedBox(width: 4.h),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 10.fSize : 11.fSize,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
