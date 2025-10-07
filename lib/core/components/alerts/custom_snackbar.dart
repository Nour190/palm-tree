import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:easy_localization/easy_localization.dart';

/// Enum for different types of snackbar
enum SnackBarType { success, error, warning, info }

/// Model class for snackbar information
class SnackBarInfo {
  final SnackBarType type;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData fallbackIcon;
  final String lottieAsset;

  const SnackBarInfo({
    required this.type,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.fallbackIcon,
    required this.lottieAsset,
  });

  static SnackBarInfo getSnackBarInfo(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return SnackBarInfo(
          type: SnackBarType.success,
          title: 'alerts.snackbar.success'.tr(),
          backgroundColor: Color(0xFF10B981),
          textColor: AppColor.white,
          borderColor: Color(0xFF059669),
          fallbackIcon: Icons.check_circle_rounded,
          lottieAsset: AppAssetsManager.success,
        );
      case SnackBarType.error:
        return SnackBarInfo(
          type: SnackBarType.error,
          title: 'alerts.snackbar.error'.tr(),
          backgroundColor: Color(0xFFEF4444),
          textColor: AppColor.white,
          borderColor: Color(0xFFDC2626),
          fallbackIcon: Icons.error_rounded,
          lottieAsset: AppAssetsManager.error,
        );
      case SnackBarType.warning:
        return SnackBarInfo(
          type: SnackBarType.warning,
          title: 'alerts.snackbar.warning'.tr(),
          backgroundColor: Color(0xFFF59E0B),
          textColor: AppColor.white,
          borderColor: Color(0xFFD97706),
          fallbackIcon: Icons.warning_rounded,
          lottieAsset: AppAssetsManager.warning,
        );
      case SnackBarType.info:
        return SnackBarInfo(
          type: SnackBarType.info,
          title: 'alerts.snackbar.info'.tr(),
          backgroundColor: Color(0xFF3B82F6),
          textColor: AppColor.white,
          borderColor: Color(0xFF2563EB),
          fallbackIcon: Icons.info_rounded,
          lottieAsset: AppAssetsManager.error,
        );
    }
  }
}

/// Custom SnackBar Widget
class CustomSnackBar extends StatefulWidget {
  final SnackBarType type;
  final String message;
  final String? title;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool showCloseButton;
  final bool showAnimation;

  const CustomSnackBar({
    Key? key,
    required this.type,
    required this.message,
    this.title,
    this.duration = const Duration(seconds: 4),
    this.onTap,
    this.onActionPressed,
    this.actionLabel,
    this.showCloseButton = true,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late SnackBarInfo _snackBarInfo;

  @override
  void initState() {
    super.initState();
    _snackBarInfo = SnackBarInfo.getSnackBarInfo(widget.type);
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSnackBarContent(),
          ),
        );
      },
    );
  }

  Widget _buildSnackBarContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 8.sH),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _snackBarInfo.backgroundColor,
            _snackBarInfo.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.sSp),
        border: Border.all(color: _snackBarInfo.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _snackBarInfo.backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sSp),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _SnackBarPatternPainter(
                  color: AppColor.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16.sSp),
      child: Padding(
        padding: EdgeInsets.all(16.sSp),
        child: Row(
          children: [
            // Animation/Icon
            _buildLeadingWidget(),
            SizedBox(width: 12.sW),
            // Text Content
            Expanded(child: _buildTextContent()),
            // Action Button
            if (widget.actionLabel != null &&
                widget.onActionPressed != null) ...[
              SizedBox(width: 12.sW),
              _buildActionButton(),
            ],
            // Close Button
            if (widget.showCloseButton) ...[
              SizedBox(width: 8.sW),
              _buildCloseButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (widget.showAnimation) {
      return Container(
        height: 40.sH,
        width: 40.sW,
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.sSp),
        ),
        child: _buildAnimationOrIcon(),
      );
    }
    return Icon(
      _snackBarInfo.fallbackIcon,
      color: _snackBarInfo.textColor,
      size: 24.sSp,
    );
  }

  Widget _buildAnimationOrIcon() {
    return Lottie.asset(
      _snackBarInfo.lottieAsset,
      height: 32.sH,
      width: 32.sW,
      fit: BoxFit.contain,
      repeat: widget.type != SnackBarType.success,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _snackBarInfo.fallbackIcon,
          color: _snackBarInfo.textColor,
          size: 24.sSp,
        );
      },
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: TextStyleHelper.instance.body14MediumInter.copyWith(
              color: _snackBarInfo.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (widget.title != null) SizedBox(height: 2.sH),
        Text(
          widget.message,
          style: TextStyleHelper.instance.body14RegularInter.copyWith(
            color: _snackBarInfo.textColor.withOpacity(0.95),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.sSp),
        border: Border.all(color: AppColor.white.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: widget.onActionPressed,
        borderRadius: BorderRadius.circular(8.sSp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 8.sH),
          child: Text(
            widget.actionLabel!,
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              color: _snackBarInfo.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      borderRadius: BorderRadius.circular(20.sSp),
      child: Container(
        padding: EdgeInsets.all(4.sSp),
        child: Icon(
          Icons.close_rounded,
          color: _snackBarInfo.textColor.withOpacity(0.8),
          size: 18.sSp,
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class _SnackBarPatternPainter extends CustomPainter {
  final Color color;

  _SnackBarPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create subtle dots pattern
    const spacing = 15.0;
    const radius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension for easy usage
extension CustomSnackBarHelper on BuildContext {
  void showCustomSnackBar({
    required SnackBarType type,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    VoidCallback? onActionPressed,
    String? actionLabel,
    bool showCloseButton = true,
    bool showAnimation = true,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: CustomSnackBar(
        type: type,
        message: message,
        title: title,
        duration: duration,
        onTap: onTap,
        onActionPressed: onActionPressed,
        actionLabel: actionLabel,
        showCloseButton: showCloseButton,
        showAnimation: showAnimation,
      ),
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  // Convenience methods
  void showSuccessSnackBar(
      String message, {
        String? title,
        VoidCallback? onTap,
      }) {
    showCustomSnackBar(
      type: SnackBarType.success,
      message: message,
      title: title ?? 'alerts.snackbar.success'.tr(),
      onTap: onTap,
    );
  }

  void showErrorSnackBar(
      String message, {
        String? title,
        VoidCallback? onTap,
        VoidCallback? onRetry,
      }) {
    showCustomSnackBar(
      type: SnackBarType.error,
      message: message,
      title: title ?? 'alerts.snackbar.error'.tr(),
      onTap: onTap,
      actionLabel: onRetry != null ? 'alerts.snackbar.retry'.tr() : null,
      onActionPressed: onRetry,
    );
  }

  void showWarningSnackBar(
      String message, {
        String? title,
        VoidCallback? onTap,
      }) {
    showCustomSnackBar(
      type: SnackBarType.warning,
      message: message,
      title: title ?? 'alerts.snackbar.warning'.tr(),
      onTap: onTap,
    );
  }

  void showInfoSnackBar(String message, {String? title, VoidCallback? onTap}) {
    showCustomSnackBar(
      type: SnackBarType.info,
      message: message,
      title: title ?? 'alerts.snackbar.info'.tr(),
      onTap: onTap,
    );
  }
}
