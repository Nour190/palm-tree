import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtWorkCardWidget extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback? onTap;

  const ArtWorkCardWidget({super.key, required this.artwork, this.onTap});

  @override
  State<ArtWorkCardWidget> createState() => _ArtWorkCardWidgetState();
}

class _ArtWorkCardWidgetState extends State<ArtWorkCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: 0.98,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  bool _hovered = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    final art = widget.artwork;
    final artistName = art.artistName ?? '';
    final artistImg = art.artistProfileImage;
    final cover = _pickCover(art);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: GestureDetector(
              onTapDown: (_) => _ctrl.forward(),
              onTapUp: (_) {
                _ctrl.reverse();
                widget.onTap?.call();
              },
              onTapCancel: () => _ctrl.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12130F) : AppColor.white,
                  borderRadius: BorderRadius.circular(24.h),
                  border: isDark
                      ? null
                      : Border.all(
                          color: _hovered
                              ? AppColor.gray900.withOpacity(0.3)
                              : AppColor.gray900,
                          width: 1.h,
                        ),
                  boxShadow: [
                    if (_hovered)
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  spacing: 16.h,
                  children: [
                    // Artwork image
                    Hero(
                      tag: 'artwork_${art.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.h),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.h),
                          child: _NetImage(
                            url: cover,
                            width: 286.h,
                            height: 310.h,
                          ),
                        ),
                      ),
                    ),

                    // Right content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyleHelper
                                .instance
                                .headline24MediumInter
                                .copyWith(
                                  color: isDark
                                      ? const Color(0xFFFFFFFF)
                                      : AppColor.gray900,
                                  letterSpacing: -0.5,
                                ),
                            child: Text(
                              art.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Description
                          if ((art.description ?? '').isNotEmpty)
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyleHelper.instance.title16LightInter
                                  .copyWith(
                                    color: isDark
                                        ? const Color(
                                            0xFFFFFFFF,
                                          ).withOpacity(0.8)
                                        : AppColor.gray900.withOpacity(0.7),
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                              child: Text(
                                art.description!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          SizedBox(height: 12.h),

                          // Materials / Vision tags (optional quick chips)
                          Wrap(
                            spacing: 8.h,
                            runSpacing: 8.h,
                            children: [
                              if ((art.materials ?? '').isNotEmpty)
                                _Chip(text: 'Materials', subtle: true),
                              if ((art.vision ?? '').isNotEmpty)
                                _Chip(text: 'Vision', subtle: true),
                            ],
                          ),

                          SizedBox(height: 28.h),

                          // Artist row
                          Row(
                            spacing: 12.h,
                            children: [
                              _Avatar(url: artistImg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artistName,
                                      style: TextStyleHelper
                                          .instance
                                          .headline24MediumInter
                                          .copyWith(
                                            color: isDark
                                                ? const Color(0xFFFFFFFF)
                                                : AppColor.gray900,
                                            fontSize: 18.h,
                                            letterSpacing: -0.3,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Artist',
                                      style: TextStyleHelper
                                          .instance
                                          .title16LightInter
                                          .copyWith(
                                            color: isDark
                                                ? const Color(
                                                    0xFFFFFFFF,
                                                  ).withOpacity(0.6)
                                                : AppColor.gray900.withOpacity(
                                                    0.6,
                                                  ),
                                            fontSize: 14.h,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(_hovered ? 1.05 : 1.0),
                                child: _CircleButton(
                                  onPressed: widget.onTap,
                                  icon: Icons.arrow_forward,
                                  size: 56.h,
                                  bg: isDark
                                      ? const Color(0xFFFFFFFF)
                                      : AppColor.gray900,
                                  fg: isDark
                                      ? AppColor.gray900
                                      : AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _pickCover(Artwork a) {
    if (a.gallery.isNotEmpty) return a.gallery.first;
    return null; // fallback image handles this
  }
}

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
    if (url == null || url!.isEmpty) {
      return _placeholder();
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: width,
      height: height,
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
      width: width,
      height: height,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(Icons.image, size: 40.h, color: Colors.grey),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.gray900.withOpacity(0.1),
          width: 2.h,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 54.h,
          height: 54.h,
          child: (url == null || url!.isEmpty)
              ? _ph()
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph(),
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _ph(),
                        Center(
                          child: SizedBox(
                            width: 14.h,
                            height: 14.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _ph() => Container(
    color: Colors.grey[300],
    alignment: Alignment.center,
    child: Icon(Icons.person, size: 24.h, color: Colors.grey),
  );
}

class _Chip extends StatelessWidget {
  final String text;
  final bool subtle;
  const _Chip({required this.text, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final bg = subtle
        // ignore: deprecated_member_use
        ? AppColor.blueGrey.withOpacity(0.08)
        : AppColor.primaryColor;
    final fg = subtle ? AppColor.gray700 : AppColor.white;

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

class _CircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color bg;
  final Color fg;

  const _CircleButton({
    required this.onPressed,
    required this.icon,
    required this.size,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg),
        ),
      ),
    );
  }
}
