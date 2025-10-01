import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';

/// Enum for different types of errors
enum ErrorType {
  network,
  server,
  notFound,
  timeout,
  generic,
  noInternet,
  unauthorized,
  warning,
}

/// Model class for error information
class ErrorInfo {
  final ErrorType type;
  final String title;
  final String message;
  final String? details;
  final IconData fallbackIcon;

  const ErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    this.details,
    required this.fallbackIcon,
  });

  static ErrorInfo getErrorInfo(
    ErrorType type, {
    String? customMessage,
    String? details,
  }) {
    switch (type) {
      case ErrorType.network:
        return ErrorInfo(
          type: type,
          title: 'Connection Problem',
          message:
              customMessage ??
              'Please check your internet connection and try again.',
          details: details,
          fallbackIcon: Icons.wifi_off_rounded,
        );
      case ErrorType.server:
        return ErrorInfo(
          type: type,
          title: 'Server Error',
          message:
              customMessage ??
              'Something went wrong on our end. Please try again later.',
          details: details,
          fallbackIcon: Icons.cloud_off_rounded,
        );
      case ErrorType.notFound:
        return ErrorInfo(
          type: type,
          title: 'Not Found',
          message:
              customMessage ??
              'The content you\'re looking for doesn\'t exist.',
          details: details,
          fallbackIcon: Icons.search_off_rounded,
        );
      case ErrorType.timeout:
        return ErrorInfo(
          type: type,
          title: 'Request Timeout',
          message:
              customMessage ??
              'The request is taking too long. Please try again.',
          details: details,
          fallbackIcon: Icons.access_time_rounded,
        );
      case ErrorType.noInternet:
        return ErrorInfo(
          type: type,
          title: 'No Internet',
          message:
              customMessage ?? 'Please check your connection and try again.',
          details: details,
          fallbackIcon: Icons.signal_wifi_off_rounded,
        );
      case ErrorType.unauthorized:
        return ErrorInfo(
          type: type,
          title: 'Access Denied',
          message:
              customMessage ??
              'You don\'t have permission to access this resource.',
          details: details,
          fallbackIcon: Icons.lock_outline_rounded,
        );
      case ErrorType.warning:
        return ErrorInfo(
          type: type,
          title: 'Warning',
          message:
              customMessage ?? 'Please review the information and try again.',
          details: details,
          fallbackIcon: Icons.warning_rounded,
        );
      default:
        return ErrorInfo(
          type: type,
          title: 'Oops! Something Went Wrong',
          message:
              customMessage ??
              'An unexpected error occurred. Please try again.',
          details: details,
          fallbackIcon: Icons.error_outline_rounded,
        );
    }
  }
}

/// Beautiful Error Page Widget
class ErrorPage extends StatefulWidget {
  final ErrorType errorType;
  final String? customMessage;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onContactSupport;
  final bool showDetails;
  final bool canRetry;
  final bool canContactSupport;
  final String lottieAsset;

  const ErrorPage({
    Key? key,
    required this.errorType,
    this.customMessage,
    this.details,
    this.onRetry,
    this.onContactSupport,
    this.showDetails = false,
    this.canRetry = true,
    this.canContactSupport = true,
    this.lottieAsset = 'assets/animations/error.json',
  }) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ErrorInfo _errorInfo;
  bool _isRetrying = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _errorInfo = ErrorInfo.getErrorInfo(
      widget.errorType,
      customMessage: widget.customMessage,
      details: widget.details,
    );
    _showDetails = widget.showDetails;
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;

    setState(() => _isRetrying = true);

    try {
      widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.sW),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildAnimation(),
                  SizedBox(height: 48.sH),
                  _buildContent(),
                  if (_errorInfo.details != null) ...[
                    SizedBox(height: 24.sH),
                    _buildDetailsSection(),
                  ],
                  const Spacer(flex: 3),
                  _buildActionButtons(),
                  SizedBox(height: 32.sH),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return Container(
      height: 200.sH,
      width: 200.sW,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.sSp),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray50, AppColor.gray100],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray200.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.sSp),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background pattern
            Positioned.fill(child: CustomPaint(painter: _PatternPainter())),
            // Animation
            Lottie.asset(
              widget.lottieAsset,
              height: 120.sH,
              width: 120.sW,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      height: 80.sH,
      width: 80.sW,
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40.sSp),
      ),
      child: Icon(
        _errorInfo.fallbackIcon,
        size: 48.sSp,
        color: AppColor.primaryColor,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Title
        Text(
          _errorInfo.title,
          style: TextStyleHelper.instance.headline28BoldInter.copyWith(
            color: AppColor.gray900,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.sH),
        // Message
        Text(
          _errorInfo.message,
          style: TextStyleHelper.instance.body16MediumInter.copyWith(
            color: AppColor.gray600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showDetails = !_showDetails),
          borderRadius: BorderRadius.circular(12.sSp),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 12.sH),
            decoration: BoxDecoration(
              color: AppColor.gray50,
              borderRadius: BorderRadius.circular(12.sSp),
              border: Border.all(color: AppColor.gray200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Technical Details',
                  style: TextStyleHelper.instance.body14MediumInter.copyWith(
                    color: AppColor.gray700,
                  ),
                ),
                SizedBox(width: 8.sW),
                AnimatedRotation(
                  turns: _showDetails ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColor.gray700,
                    size: 20.sSp,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: _showDetails
              ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 12.sH),
                  padding: EdgeInsets.all(16.sSp),
                  decoration: BoxDecoration(
                    color: AppColor.gray900.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.sSp),
                    border: Border.all(color: AppColor.gray200),
                  ),
                  child: Text(
                    _errorInfo.details!,
                    style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      color: AppColor.gray700,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Button (Retry)
        if (widget.canRetry && widget.onRetry != null)
          Container(
            width: double.infinity,
            height: 56.sH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.sSp),
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor,
                  AppColor.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isRetrying ? null : _handleRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColor.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sSp),
                ),
              ),
              child: _isRetrying
                  ? SizedBox(
                      height: 24.sH,
                      width: 24.sW,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 24.sSp),
                        SizedBox(width: 12.sW),
                        Text(
                          'Try Again',
                          style: TextStyleHelper.instance.body16MediumInter
                              .copyWith(
                                color: AppColor.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
            ),
          ),

        // Secondary Button (Contact Support)
        if (widget.canContactSupport && widget.onContactSupport != null) ...[
          SizedBox(height: 16.sH),
          SizedBox(
            width: double.infinity,
            height: 56.sH,
            child: OutlinedButton(
              onPressed: widget.onContactSupport,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.gray700,
                side: BorderSide(color: AppColor.gray200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sSp),
                ),
                backgroundColor: AppColor.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_mic_rounded, size: 22.sSp),
                  SizedBox(width: 10.sW),
                  Text(
                    'Contact Support',
                    style: TextStyleHelper.instance.body16MediumInter.copyWith(
                      color: AppColor.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.gray200.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension for easy usage
extension ErrorPageHelper on BuildContext {
  void showErrorPage({
    required ErrorType errorType,
    String? customMessage,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onContactSupport,
    bool showDetails = false,
    bool canRetry = true,
    bool canContactSupport = true,
  }) {
    // Determine the appropriate Lottie asset
    String lottieAsset = errorType == ErrorType.warning
        ? 'assets/animations/warning.json'
        : 'assets/animations/error.json';

    Navigator.of(this).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ErrorPage(
          errorType: errorType,
          customMessage: customMessage,
          details: details,
          onRetry: onRetry,
          onContactSupport: onContactSupport,
          showDetails: showDetails,
          canRetry: canRetry,
          canContactSupport: canContactSupport,
          lottieAsset: lottieAsset,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
