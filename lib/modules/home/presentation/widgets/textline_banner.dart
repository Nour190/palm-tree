import 'dart:math' as math;
import 'dart:ui' as ui; // Added dart:ui import to explicitly use Flutter's TextDirection
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TextLineBanner extends StatefulWidget {
  const TextLineBanner({
    super.key,
    this.text = 'FINEST DATES  *  YOUR DATE WITH THE  *',
    this.enableMarquee = true,
    this.speed = 50.0, // pixels/second
    this.gap = 50.0,
    this.height = 65.0,
    this.backgroundColor,
    this.textStyle,
    this.showGlow = true,
    this.showShimmer = true,
    this.showEntryAnimation = true,
  });

  final String text;
  final bool enableMarquee;
  final double speed; // px/sec
  final double gap;
  final double height;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool showGlow;
  final bool showShimmer;
  final bool showEntryAnimation;

  @override
  State<TextLineBanner> createState() => _TextLineBannerState();
}

class _TextLineBannerState extends State<TextLineBanner>
    with TickerProviderStateMixin {
  late AnimationController _marqueeController;
  late AnimationController _glowController;
  late AnimationController _entryController;
  late AnimationController _shimmerController;

  double? _cachedTextWidth;
  String? _cachedText;
  TextStyle? _cachedStyle;
  double _lastCycleWidth = -1;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(vsync: this);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.showGlow) _glowController.repeat(reverse: true);
    if (widget.showEntryAnimation) _entryController.forward();
    if (widget.showShimmer) _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(covariant TextLineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Toggle side animations safely
    _toggle(_glowController, widget.showGlow, reverse: true);
    _toggle(_shimmerController, widget.showShimmer);
    if (widget.showEntryAnimation && _entryController.value == 0.0) {
      _entryController.forward();
    }
    // Bust text-width cache if content/style changed
    if (oldWidget.text != widget.text ||
        oldWidget.textStyle != widget.textStyle) {
      _cachedTextWidth = null;
    }
  }

  void _toggle(AnimationController c, bool enabled, {bool reverse = false}) {
    if (enabled) {
      if (!c.isAnimating) c.repeat(reverse: reverse);
    } else {
      c.stop();
      c.value = 0.0;
    }
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    _glowController.dispose();
    _entryController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  TextStyle get _textStyle {
    final styles = TextStyleHelper.instance;
    return (widget.textStyle ?? styles.display40BoldInter).copyWith(
      fontSize: 22.h,
    );
  }

  ui.TextDirection _getTextDirection(BuildContext context) {
    try {
      final locale = context.locale;
      return locale.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
    } catch (e) {
      return ui.TextDirection.ltr;
    }
  }

  double _measureTextWidth() {
    final t = widget.text;
    final s = _textStyle;
    if (_cachedTextWidth != null && _cachedText == t && _cachedStyle == s) {
      return _cachedTextWidth!;
    }
    final painter = TextPainter(
      text: TextSpan(text: t, style: s),
      textDirection: ui.TextDirection.ltr, // Keep LTR for measurement consistency
      maxLines: 1,
    )..layout();
    _cachedTextWidth = painter.width;
    _cachedText = t;
    _cachedStyle = s;
    return _cachedTextWidth!;
  }

  void _ensureMarquee(double cycleWidth) {
    if (!widget.enableMarquee || widget.speed <= 0) {
      _marqueeController.stop();
      _marqueeController.value = 0.0;
      return;
    }
    if ((cycleWidth - _lastCycleWidth).abs() > 0.5 ||
        _marqueeController.duration == null) {
      _lastCycleWidth = cycleWidth;
      final seconds = (cycleWidth / widget.speed).clamp(0.016, 600.0);
      _marqueeController
        ..stop()
        ..duration = Duration(milliseconds: (seconds * 1000).round())
        ..repeat();
    }
  }

  Widget _buildShimmerOverlay() {
    if (!widget.showShimmer) return const SizedBox.shrink();
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          final v = _shimmerController.value; // 0..1
          return IgnorePointer(
            ignoring: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.5 + 3 * v, 0),
                  end: Alignment(-0.5 + 3 * v, 0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.10),
                    Colors.white.withOpacity(0.20),
                    Colors.white.withOpacity(0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = _getTextDirection(context);

    Widget banner = Container(
      height: widget.height.h,
      width: double.infinity,
      color: widget.backgroundColor ?? AppColor.gray900,
      padding: EdgeInsets.symmetric(horizontal: 15.sW),
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textWidth = _measureTextWidth();
          final cycleWidth = textWidth + widget.gap;

          // Keep marquee speed in sync with measured cycle width
          _ensureMarquee(cycleWidth);

          // Build painter-driven marquee (no Row => no RenderFlex)
          final painter = _MarqueePainter(
            text: widget.text,
            style: _textStyle.copyWith(
              shadows: widget.showGlow
                  ? [
                Shadow(
                  color: Colors.white.withOpacity(
                    0.3 +
                        0.4 *
                            (math.sin(
                              _glowController.value * math.pi * 2,
                            ) +
                                1) /
                            2,
                  ),
                  blurRadius:
                  8 +
                      15 *
                          ((math.sin(
                            _glowController.value * math.pi * 2,
                          ) +
                              1) /
                              2),
                ),
                Shadow(
                  color: AppColor.whiteCustom.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ]
                  : null,
            ),
            gap: widget.gap,
            // progress 0..1 across one cycle
            progress: widget.enableMarquee ? _marqueeController.value : 0.0,
            textDirection: textDirection,
          );

          Widget content = RepaintBoundary(
            child: CustomPaint(
              painter: painter,
              size: Size(constraints.maxWidth, constraints.maxHeight),
              isComplex: true,
              willChange: widget.enableMarquee,
            ),
          );

          if (widget.showShimmer) {
            content = Stack(children: [content, _buildShimmerOverlay()]);
          }
          return content;
        },
      ),
    );

    if (widget.showEntryAnimation) {
      banner = AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryController,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position:
              Tween<Offset>(
                begin: const Offset(0, -0.25),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            ),
          );
        },
        child: banner,
      );
    }

    return banner;
  }
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter({
    required this.text,
    required this.style,
    required this.gap,
    required this.progress,
    required this.textDirection,
  }) : super(repaint: null);

  final String text;
  final TextStyle style;
  final double gap;
  final double progress; // 0..1
  final ui.TextDirection textDirection; // Updated field type to ui.TextDirection

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();

    final textW = tp.width;
    final textH = tp.height;
    final cycle = textW + gap;
    final dy = (size.height - textH) / 2;

    // Offset goes from 0..cycle, negative to move left
    final dx0 = -(progress * cycle);

    // Start a little left so the first painted copy can cover the gap
    double start = dx0;
    while (start > -cycle) start -= cycle;

    // Paint copies across visible width (+1 buffer)
    for (double x = start; x < size.width + cycle; x += cycle) {
      tp.paint(canvas, Offset(x, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _MarqueePainter old) {
    return old.text != text ||
        old.style != style ||
        old.gap != gap ||
        old.progress != progress ||
        old.textDirection != textDirection;
  }
}
