import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtistCardWidget extends StatefulWidget {
  final Artist artist;
  final VoidCallback? onTap;

  const ArtistCardWidget({super.key, required this.artist, this.onTap});

  @override
  State<ArtistCardWidget> createState() => _ArtistCardWidgetState();
}

class _ArtistCardWidgetState extends State<ArtistCardWidget> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.artist;
    final cityCountry = _cityCountry(a.city, a.country);

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedPhysicalModel(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            elevation: _hovered ? 8.0 : 2.0,
            color: AppColor.white,
            shadowColor: AppColor.black.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12.h),
            shape: BoxShape.rectangle,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.h),
                onTap: widget.onTap,
                onHighlightChanged: (isPressed) =>
                    setState(() => _pressed = isPressed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left image (network w/ fade-in & fallback)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.h),
                        bottomLeft: Radius.circular(12.h),
                      ),
                      child: SizedBox(
                        width: 100.h,
                        height: 120.h,
                        child: _ProfileImage(url: a.profileImage),
                      ),
                    ),

                    // Right content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + location chip + LIVE badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    a.name,
                                    style: TextStyleHelper
                                        .instance
                                        .title16BoldInter
                                        .copyWith(
                                          fontSize: 18.fSize,
                                          color: AppColor.black,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.h),
                                if (cityCountry.isNotEmpty)
                                  _Chip(
                                    text: cityCountry,
                                    bg: AppColor.green.withOpacity(0.08),
                                    fg: AppColor.gray700,
                                  ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Live/status row
                            if (a.isLive || (a.platform?.isNotEmpty ?? false))
                              Row(
                                children: [
                                  if (a.isLive) _LiveDot(label: 'LIVE'),
                                  if (a.isLive &&
                                      (a.platform?.isNotEmpty ?? false))
                                    SizedBox(width: 10.h),
                                  if (a.platform?.isNotEmpty ?? false)
                                    _Chip(
                                      text: a.platform!,
                                      bg: AppColor.blueGrey.withOpacity(0.08),
                                      fg: AppColor.gray700,
                                    ),
                                ],
                              ),

                            if (a.isLive || (a.platform?.isNotEmpty ?? false))
                              SizedBox(height: 8.h),

                            // Bio / About
                            if ((a.about ?? '').isNotEmpty)
                              Text(
                                a.about!,
                                style: TextStyleHelper
                                    .instance
                                    .title16RegularInter
                                    .copyWith(
                                      fontSize: 12.fSize,
                                      color: AppColor.gray700,
                                      height: 1.4,
                                    ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _cityCountry(String? city, String? country) {
    final c1 = (city ?? '').trim();
    final c2 = (country ?? '').trim();
    if (c1.isEmpty && c2.isEmpty) return '';
    if (c1.isEmpty) return c2;
    if (c2.isEmpty) return c1;
    return '$c1, $c2';
  }
}

class _ProfileImage extends StatelessWidget {
  final String? url;
  const _ProfileImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSync) => AnimatedOpacity(
        opacity: wasSync || frame != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: child,
      ),
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _placeholder(),
            Center(
              child: SizedBox(
                width: 18.h,
                height: 18.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 40.h, color: Colors.grey),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.fSize,
          color: fg,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  final String label;
  const _LiveDot({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColor.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.h,
            height: 6.h,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.fSize,
              fontWeight: FontWeight.w600,
              color: Colors.red,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
