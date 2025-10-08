import 'package:flutter/material.dart';

/// A widget that creates a parallax scrolling effect for a background image.
/// The background scrolls slower than the content, creating depth.
class ParallaxBackground extends StatefulWidget {
  final Widget child;
  final String backgroundImage;
  final double parallaxFactor;
  final Color? overlayColor;
  final double overlayOpacity;

  const ParallaxBackground({
    super.key,
    required this.child,
    required this.backgroundImage,
    this.parallaxFactor = 0.5, // 0.5 means background moves at half speed
    this.overlayColor,
    this.overlayOpacity = 0.0,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, -_scrollOffset * widget.parallaxFactor),
            child: Image.asset(
              widget.backgroundImage,
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        
        if (widget.overlayColor != null)
          Positioned.fill(
            child: Container(
              color: widget.overlayColor!.withOpacity(widget.overlayOpacity),
            ),
          ),
        
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              setState(() {
                _scrollOffset = notification.metrics.pixels;
              });
            }
            return false;
          },
          child: widget.child,
        ),
      ],
    );
  }
}

/// A simpler version that wraps a SingleChildScrollView with parallax background
class ParallaxScrollView extends StatelessWidget {
  final Widget child;
  final String backgroundImage;
  final double parallaxFactor;
  final Color? overlayColor;
  final double overlayOpacity;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ParallaxScrollView({
    super.key,
    required this.child,
    required this.backgroundImage,
    this.parallaxFactor = 0.5,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) => true,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight * 2,
                    child: Image.asset(
                      backgroundImage,
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeatY,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              
              if (overlayColor != null)
                Positioned.fill(
                  child: Container(
                    color: overlayColor!.withOpacity(overlayOpacity),
                  ),
                ),
              
              SingleChildScrollView(
                physics: physics,
                padding: padding,
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
}
