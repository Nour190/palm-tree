import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

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
  });

  final String title;
  final String about;
  final String? materials;
  final String? vision;
  final List<String> galleryImages;

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  bool _aboutExpanded = false;
  bool _visionExpanded = false;
  late final String? _hero; // single image path or null

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
    final isDesktop = w >= 1200;
    final isTablet = w >= 840 && w < 1200;
    final isMobile = w < 840;

    final double gap = 16.h;
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
            title: 'About',
            body: about,
            styles: s,
            expanded: _aboutExpanded,
            onToggle: () => setState(() => _aboutExpanded = !_aboutExpanded),
          ),
        if (hasAbout && (hasMaterials || hasVision)) SizedBox(height: gap),
        if (hasMaterials)
          _materialsSection(title: 'Materials', raw: materialsRaw!, styles: s),
        if (hasMaterials && hasVision) SizedBox(height: gap),
        if (hasVision)
          _textSection(
            title: 'Vision',
            body: visionRaw!,
            styles: s,
            expanded: _visionExpanded,
            onToggle: () => setState(() => _visionExpanded = !_visionExpanded),
            isQuote: true,
          ),
      ],
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layout: mobile stacks; tablet/desktop split text + image
          if (isMobile) ...[
            if (_hero != null) _roundedImage(_hero!, height: heroH),
            if (_hero != null) SizedBox(height: gap),
            leftColumn,
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // text first
                Expanded(flex: 6, child: leftColumn),
                SizedBox(width: gap),
                // image second
                if (_hero != null)
                  Expanded(
                    flex: 5,
                    child: _roundedImage(_hero!, height: heroH),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------ Pieces ------------------------------------------

  Widget _header({required String title, required TextStyleHelper styles}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.white),
          SizedBox(width: 10.h),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.headline24MediumInter.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(width: 8.h),
          _copyButton(text: title),
        ],
      ),
    );
  }

  Widget _copyButton({required String text}) => Tooltip(
    message: 'Copy',
    child: InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: text));
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied')));
      },
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        padding: EdgeInsets.all(8.h),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: const Icon(Icons.copy_all, color: Colors.white, size: 18),
      ),
    ),
  );

  Widget _textSection({
    required String title,
    required String body,
    required TextStyleHelper styles,
    required bool expanded,
    required VoidCallback onToggle,
    bool isQuote = false,
  }) {
    final border = isQuote
        ? Border(
            left: BorderSide(color: Colors.black.withOpacity(0.35), width: 4),
          )
        : null;

    final textWidget = Text(
      body,
      key: ValueKey<String>('about_body_${title.hashCode}'),
      style: styles.title16LightInter.copyWith(
        color: AppColor.gray900,
        height: 1.5,
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
            style: styles.headline24MediumInter.copyWith(
              color: AppColor.gray900,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(border: border),
            padding: EdgeInsets.only(left: isQuote ? 12.h : 0),
            child: textWidget,
          ),
          if (body.length > 500) ...[
            SizedBox(height: 6.h),
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(expanded ? 'Show less' : 'Read more'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
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
          style: styles.headline24MediumInter.copyWith(color: AppColor.gray900),
        ),
        SizedBox(height: 8.h),
        ...bullets.map(
          (line) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: Colors.black),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: Text(
                    line,
                    style: styles.title16LightInter.copyWith(
                      color: AppColor.gray900,
                      height: 1.45,
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
    final radius = BorderRadius.circular(18.h);
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
}
