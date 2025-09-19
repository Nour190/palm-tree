import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';

/// Lightweight skeleton placeholders for Home initial load.
/// Keeps layout stable and feels faster than a full-screen spinner.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final device = Responsive.deviceTypeOf(context);
    final bool isTablet = device == DeviceType.tablet;
    final bool isDesktop = device == DeviceType.desktop;

    final double horizontalPad = isDesktop
        ? 48.sW
        : isTablet
            ? 32.sW
            : 18.sW;
    final double topPad = isDesktop
        ? 40.sH
        : isTablet
            ? 32.sH
            : 24.sH;
    final double sectionGap = isDesktop
        ? 40.sH
        : isTablet
            ? 32.sH
            : 24.sH;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontalPad, topPad, horizontalPad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderSkeleton(),
                SizedBox(height: sectionGap),
                _SectionTitleSkeleton(width: 180.sW),
                SizedBox(height: 12.sH),
                _HorizontalCardsSkeleton(
                  height: isDesktop
                      ? 300.sH
                      : isTablet
                          ? 300.sH
                          : 240.sH,
                  itemWidth: isDesktop
                      ? 360.sW
                      : isTablet
                          ? 320.sW
                          : 210.sW,
                ),
                SizedBox(height: sectionGap),
                _SectionTitleSkeleton(width: 160.sW),
                SizedBox(height: 12.sH),
                _HorizontalCardsSkeleton(
                  height: isDesktop
                      ? 240.sH
                      : isTablet
                          ? 300.sH
                          : 240.sH,
                  itemWidth: isDesktop
                      ? 420.sW
                      : isTablet
                          ? 320.sW
                          : 210.sW,
                ),
                SizedBox(height: sectionGap),
                _SectionTitleSkeleton(width: 120.sW),
                SizedBox(height: 12.sH),
                _GalleryGridSkeleton(
                  columns: isDesktop
                      ? 6
                      : isTablet
                          ? 4
                          : 3,
                ),
                SizedBox(height: sectionGap),
                _SectionTitleSkeleton(width: 140.sW),
                SizedBox(height: 12.sH),
                _ReviewsStripSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Bar(widthFactor: 0.52, height: 28),
        SizedBox(height: 10),
        _Bar(widthFactor: 0.34, height: 20),
        SizedBox(height: 18),
        _RoundedRect(height: 160),
      ],
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _Bar.fixed(width: width, height: 20),
    );
  }
}

class _HorizontalCardsSkeleton extends StatelessWidget {
  const _HorizontalCardsSkeleton({
    required this.height,
    required this.itemWidth,
    this.count = 4,
  });

  final double height;
  final double itemWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        separatorBuilder: (_, __) => SizedBox(width: 14.sW),
        itemBuilder: (_, __) => const _RoundedRect(),
      ),
    );
  }
}

class _GalleryGridSkeleton extends StatelessWidget {
  const _GalleryGridSkeleton({required this.columns});
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12.sW,
        crossAxisSpacing: 12.sW,
      ),
      itemCount: rows * columns,
      itemBuilder: (_, __) => const _RoundedRect(),
    );
  }
}

class _ReviewsStripSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.sH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.sW),
        itemBuilder: (_, __) => const _RoundedRect(),
      ),
    );
  }
}

class _RoundedRect extends StatelessWidget {
  const _RoundedRect({this.height = 180});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210.sW,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.widthFactor, required this.height}) : fixedWidth = null;
  const _Bar.fixed({required double width, required this.height})
      : widthFactor = null,
        fixedWidth = width;

  final double? widthFactor;
  final double? fixedWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double width = fixedWidth ?? MediaQuery.sizeOf(context).width * (widthFactor ?? 0.5);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

