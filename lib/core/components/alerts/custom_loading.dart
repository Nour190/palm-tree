import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:easy_localization/easy_localization.dart';

/// Enum for different types of loading states
enum LoadingType { page, overlay, button, inline, skeleton }

/// Loading configuration model
class LoadingConfig {
  final LoadingType type;
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool showLottie;
  final bool showMessage;
  final bool isDismissible;
  final double? size;

  const LoadingConfig({
    required this.type,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.showLottie = true,
    this.showMessage = true,
    this.isDismissible = false,
    this.size,
  });
}

/// Premium Loading Page Component
class LoadingPage extends StatefulWidget {
  final String? message;
  final String? subtitle;
  final bool showLottie;
  final String lottieAsset;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const LoadingPage({
    Key? key,
    this.message,
    this.subtitle,
    this.showLottie = true,
    this.lottieAsset = 'assets/animations/loading.json',
    this.onCancel,
    this.showCancelButton = false,
  }) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingAnimation(),
                SizedBox(height: 32.sH),
                _buildContent(),
                if (widget.showCancelButton) ...[
                  SizedBox(height: 40.sH),
                  _buildCancelButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Container(
      height: 120.sH,
      width: 120.sW,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(20.sSp),
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [
      //       AppColor.primaryColor.withOpacity(0.1),
      //       AppColor.primaryColor.withOpacity(0.05),
      //     ],
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: AppColor.primaryColor.withOpacity(0.1),
      //       blurRadius: 20,
      //       offset: const Offset(0, 10),
      //     ),
      //   ],
      // ),
      child: widget.showLottie
          ? Lottie.asset(
        widget.lottieAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackSpinner(),
      )
          : _buildFallbackSpinner(),
    );
  }

  Widget _buildFallbackSpinner() {
    return Center(
      child: SizedBox(
        height: 40.sH,
        width: 40.sW,
        child: Icon(
          Icons.hourglass_empty,
          size: 40.sSp,
          color: AppColor.primaryColor,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        if (widget.message != null)
          Text(
            widget.message!,
            style: TextStyleHelper.instance.headline20BoldInter.copyWith(
              color: AppColor.gray900,
            ),
            textAlign: TextAlign.center,
          ),
        if (widget.subtitle != null) ...[
          SizedBox(height: 8.sH),
          Text(
            widget.subtitle!,
            style: TextStyleHelper.instance.body16MediumInter.copyWith(
              color: AppColor.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: widget.onCancel,
      child: Text(
        'alerts.loading.cancel'.tr(),
        style: TextStyleHelper.instance.body16MediumInter.copyWith(
          color: AppColor.gray700,
        ),
      ),
    );
  }
}

/// Overlay Loading Component
class LoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? overlayColor;
  final bool showLottie;
  final String lottieAsset;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor,
    this.showLottie = true,
    this.lottieAsset = 'assets/animations/loading.json',
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      widget.isLoading ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          FadeTransition(
            opacity: _animation,
            child: Container(
              color: widget.overlayColor ?? AppColor.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.sSp),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(16.sSp),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 60.sH,
                        width: 60.sW,
                        child: widget.showLottie
                            ? Lottie.asset(
                          widget.lottieAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.hourglass_empty,
                                size: 40.sSp,
                                color: AppColor.primaryColor,
                              ),
                        )
                            : // Replaced CircularProgressIndicator with icon
                        Icon(
                          Icons.hourglass_empty,
                          size: 40.sSp,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      if (widget.message != null) ...[
                        SizedBox(height: 16.sH),
                        Text(
                          widget.message!,
                          style: TextStyleHelper.instance.body16MediumInter,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Button Loading Component
class LoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 48.sH,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isLoading
                    ? [AppColor.gray400, AppColor.gray500]
                    : [
                  widget.backgroundColor ?? AppColor.primaryColor,
                  (widget.backgroundColor ?? AppColor.primaryColor)
                      .withOpacity(0.8),
                ],
              ),
              borderRadius:
              widget.borderRadius ?? BorderRadius.circular(12.sSp),
              boxShadow: widget.isLoading
                  ? []
                  : [
                BoxShadow(
                  color: (widget.backgroundColor ?? AppColor.primaryColor)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                _controller.forward().then((_) => _controller.reverse());
                widget.onPressed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: widget.textColor ?? AppColor.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  widget.borderRadius ?? BorderRadius.circular(12.sSp),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                height: 20.sH,
                width: 20.sW,
                child: Icon(
                  Icons.hourglass_empty,
                  color: widget.textColor ?? AppColor.white,
                  size: 20.sSp,
                ),
              )
                  : Text(
                widget.text,
                style: TextStyleHelper.instance.body16MediumInter
                    .copyWith(
                  color: widget.textColor ?? AppColor.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Inline Loading Indicator
class InlineLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const InlineLoading({Key? key, this.message, this.size = 24, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hourglass_empty,
          size: size,
          color: color ?? AppColor.primaryColor,
        ),
        if (message != null) ...[
          SizedBox(width: 8),
          Text(
            message!,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: color ?? AppColor.gray700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Extension for easy usage
extension LoadingHelper on BuildContext {
  /// Show full page loading
  void showLoadingPage({
    String? message,
    String? subtitle,
    bool showLottie = true,
    VoidCallback? onCancel,
    bool showCancelButton = false,
  }) {
    Navigator.of(this).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoadingPage(
          message: message,
          subtitle: subtitle,
          showLottie: showLottie,
          onCancel: onCancel,
          showCancelButton: showCancelButton,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        opaque: false,
      ),
    );
  }

  /// Hide loading page
  void hideLoadingPage() {
    Navigator.of(this).pop();
  }
}
