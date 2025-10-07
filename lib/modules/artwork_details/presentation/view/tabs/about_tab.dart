import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:easy_localization/easy_localization.dart';

/// AboutTab — redesigned
/// • Black-primary header, no duplicated titles.
/// • Single responsive hero image (uses first of galleryImages if present).
/// • Clean sections: About, Materials (bulleted + deduped), Vision (optional quote style).
/// • Read more/less for long text. Mobile / Tablet / Web responsive layout.
class AboutTab extends StatefulWidget {
  const AboutTab({
    super.key,
    required this.title,
    required this.about,
    this.materials,
    this.vision,
    this.galleryImages = const [],
    this.onAskAi,
  });

  final String title;
  final String about;
  final String? materials;
  final String? vision;
  final List<String> galleryImages;
  final VoidCallback? onAskAi;

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  bool _aboutExpanded = false;
  bool _visionExpanded = false;
  late final String? _hero; // single image path or null
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // pick only one image, dedup list first
    final seen = LinkedHashSet<String>();
    final dedup = [
      for (final p in widget.galleryImages)
        if (seen.add(p)) p,
    ];
    _hero = dedup.isNotEmpty ? dedup.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;
    final w = SizeUtils.width;
    final isDesktop = w >= 600;
    final isTablet = w >= 840 && w < 1200;
    final isMobile = w < 840;

    final double gap = 20.h; // Increased gap for better spacing
    final double heroH = isDesktop ? 460.h : (isTablet ? 380.h : 240.h);

    final about = widget.about.trim();
    final materialsRaw = widget.materials?.trim();
    final visionRaw = widget.vision?.trim();

    final hasAbout = about.isNotEmpty;
    final hasMaterials = (materialsRaw != null && materialsRaw.isNotEmpty);
    final hasVision = (visionRaw != null && visionRaw.isNotEmpty);

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAbout)
          _textSection(
            title: 'about_artist'.tr(),
            body: about,
            styles: s,
            expanded: _aboutExpanded,
            onToggle: () => setState(() => _aboutExpanded = !_aboutExpanded),
          ),
        if (hasAbout && (hasMaterials || hasVision)) SizedBox(height: gap),
        if (hasMaterials)
          _materialsSection(title: 'materials'.tr(), raw: materialsRaw, styles: s),
        if (hasMaterials && hasVision) SizedBox(height: gap),
        if (hasVision)
          _textSection(
            title: 'vision'.tr(),
            body: visionRaw,
            styles: s,
            expanded: _visionExpanded,
            onToggle: () => setState(() => _visionExpanded = !_visionExpanded),
            isQuote: false,
          ),
        SizedBox(height: gap),
        _liveListeningSection(s),
        if (widget.galleryImages.isNotEmpty) ...[
          SizedBox(height: gap),
          _galleryImagesSection(),
        ],
        SizedBox(height: gap),
        _askAiButton(s),
      ],
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            leftColumn,
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: leftColumn),
                SizedBox(width: gap),
                if (_hero != null)
                  Expanded(
                    flex: 5,
                    child: _roundedImage(_hero, height: heroH),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _textSection({
    required String title,
    required String body,
    required TextStyleHelper styles,
    required bool expanded,
    required VoidCallback onToggle,
    bool isQuote = false,
  }) {
    final textWidget = Text(
      body,
      key: ValueKey<String>('about_body_${title.hashCode}'),
      style: styles.title16LightInter.copyWith(
        color: AppColor.gray700,
        height: 1.6,
        fontSize: 15,
      ),
      maxLines: expanded ? null : 8,
      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: ValueKey<String>('about_title_$title'),
            style: styles.headline20BoldInter.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10.h),
          textWidget,
          if (body.length > 500) ...[
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
              label: Text(expanded ? 'show_less'.tr() : 'read_more'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _materialsSection({
    required String title,
    required String raw,
    required TextStyleHelper styles,
  }) {
    final bullets = _normalizeMaterials(raw);
    if (bullets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: styles.headline20BoldInter.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10.h),
        ...bullets.map(
              (line) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: Text(
                    line,
                    style: styles.title16LightInter.copyWith(
                      color: AppColor.gray700,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _normalizeMaterials(String raw) {
    final parts = raw
        .split(RegExp(r"[;•\-•,]+"))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final seen = <String>{};
    final out = <String>[];
    for (final p in parts) {
      final key = p.toLowerCase();
      if (seen.add(key)) out.add(p);
    }
    return out;
  }

  Widget _roundedImage(String path, {required double height}) {
    final radius = BorderRadius.circular(24.h);
    final isNetwork = path.startsWith('http');

    final Widget child = isNetwork
        ? Image.network(
      path,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      frameBuilder: (context, widget, frame, wasSync) {
        return AnimatedOpacity(
          opacity: wasSync || frame != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: widget,
        );
      },
      errorBuilder: (_, __, ___) =>
      const ColoredBox(color: AppColor.backgroundGray),
    )
        : Image.asset(
      path,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(height: height, width: double.infinity, child: child),
    );
  }

  Widget _liveListeningSection(TextStyleHelper styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'live_listening'.tr(),
          style: styles.headline20BoldInter.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.h),
            border: Border.all(color: AppColor.gray200, width: 1.5),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isPlaying = !_isPlaying);
                  // TODO: Implement actual audio playback
                },
                child: Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16.h),
              Expanded(
                child: CustomPaint(
                  size: Size(double.infinity, 40.h),
                  painter: _WaveformPainter(isPlaying: _isPlaying),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _galleryImagesSection() {
    final imagesToShow = widget.galleryImages.take(4).toList();

    return Column(
      children: [
        if (imagesToShow.isNotEmpty)
          _roundedImage(imagesToShow[0], height: 240.h),
        if (imagesToShow.length > 1) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              if (imagesToShow.length > 1)
                Expanded(
                  child: _roundedImage(imagesToShow[1], height: 120.h),
                ),
              if (imagesToShow.length > 2) ...[
                SizedBox(width: 16.h),
                Expanded(
                  child: _roundedImage(imagesToShow[2], height: 120.h),
                ),
              ],
            ],
          ),
        ],
        if (imagesToShow.length > 3) ...[
          SizedBox(height: 16.h),
          _roundedImage(imagesToShow[3], height: 240.h),
        ],
      ],
    );
  }

  Widget _askAiButton(TextStyleHelper styles) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onAskAi,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.h),
          ),
          elevation: 0,
        ),
        child: Text(
          'ask_ai'.tr(),
          style: styles.title16MediumInter.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final bool isPlaying;

  _WaveformPainter({required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = 60;
    final barWidth = 2.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final heightFactor = (i % 3 == 0) ? 0.8 : (i % 2 == 0) ? 0.5 : 0.3;
      final barHeight = size.height * heightFactor;
      final y = (size.height - barHeight) / 2;

      final useActivePaint = isPlaying && i < (barCount * 0.3);

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + barHeight),
        useActivePaint ? activePaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying;
  }
}