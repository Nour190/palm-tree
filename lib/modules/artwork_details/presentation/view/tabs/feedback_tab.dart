// lib/modules/artist_details/presentation/view/tabs/feedback_tab.dart
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({
    super.key,
    this.chips = const [
      'Over Service',
      'Product',
      'Artist Support',
      'Quality',
      'Accessibility',
      'Clear Information',
      'Artwork Story',
      'Material Uniqueness',
    ],
    this.initialRating = 2,
    this.initialMessage = '',
    this.preselected = const {},
    this.onSubmit,
  });

  final List<String> chips;
  final int initialRating;
  final String initialMessage;
  final Set<String> preselected;
  final void Function(int rating, String message, Set<String> tags)? onSubmit;

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late int _rating = widget.initialRating.clamp(1, 5);
  late final TextEditingController _msgCtrl;
  late final Set<String> _selected;
  late final AnimationController _fadeController;
  late final AnimationController _starController;
  late final List<AnimationController> _chipControllers;

  // Performance optimization - cache responsive values
  late double _cachedStarSize;
  late double _cachedMaxWidth;
  late int _cachedChipColumns;
  late double _cachedButtonHeight;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _msgCtrl = TextEditingController(text: widget.initialMessage);
    _selected = {...widget.preselected};

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize chip animations
    _chipControllers = List.generate(
      widget.chips.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 150 + (index * 30)),
        vsync: this,
      ),
    );

    // Start animations
    _fadeController.forward();
    _animateChipsSequentially();
  }

  void _animateChipsSequentially() async {
    for (int i = 0; i < _chipControllers.length; i++) {
      _chipControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cacheResponsiveValues();
  }

  void _cacheResponsiveValues() {
    final deviceType = Responsive.deviceTypeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.desktop:
        _cachedStarSize = 40.sW; // Reduced from 52
        _cachedMaxWidth = 780.sW; // Reduced from 900
        _cachedChipColumns = screenWidth > 1200 ? 4 : 3;
        _cachedButtonHeight = 48.sH; // Reduced from 60
        break;
      case DeviceType.tablet:
        _cachedStarSize = 28.sW; // Reduced from 34
        _cachedMaxWidth = 580.sW; // Reduced from 680
        _cachedChipColumns = 3;
        _cachedButtonHeight = 44.sH; // Reduced from 56
        break;
      case DeviceType.mobile:
        _cachedStarSize = 32.sW; // Reduced from 40
        _cachedMaxWidth = double.infinity;
        _cachedChipColumns = 2;
        _cachedButtonHeight = 42.sH; // Reduced from 52
        break;
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _fadeController.dispose();
    _starController.dispose();
    for (final controller in _chipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          color: AppColor.white,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _cachedMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    SizedBox(height: _getSectionSpacing()),
                    _buildRatingSection(),
                    SizedBox(height: _getSectionSpacing()),
                    _buildFeedbackSection(),
                    SizedBox(height: _getSectionSpacing()),
                    _buildSubmitButton(),
                    if (Responsive.isMobile(context))
                      SizedBox(height: 80.sH), // Reduced from 100
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getSectionSpacing() {
    switch (Responsive.deviceTypeOf(context)) {
      case DeviceType.desktop:
        return 30.sH; // Reduced from 40
      case DeviceType.tablet:
        return 24.sH; // Reduced from 32
      case DeviceType.mobile:
        return 20.sH; // Reduced from 28
    }
  }

  Widget _buildHeader() {
    final s = TextStyleHelper.instance;
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Share Your Feedback',
          style: s.display48BoldInter.copyWith(
            color: AppColor.gray900,
            fontSize: Responsive.responsiveFontSize(
              context,
              isDesktop
                  ? 28 // Reduced from 36
                  : Responsive.isTablet(context)
                  ? 26 // Reduced from 32
                  : 22, // Reduced from 28
            ),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.sH), // Reduced from 12
        Text(
          'Help us improve by sharing your experience with our service',
          style: s.title16RegularInter.copyWith(
            color: AppColor.gray600,
            fontSize: Responsive.responsiveFontSize(
              context,
              14,
            ), // Reduced from 16
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return _buildSection(
      icon: Icons.star_rounded,
      iconColor: AppColor.amber,
      title: 'Rate Your Experience',
      subtitle: 'How satisfied are you with our service?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 18.sH), // Reduced from 24
          _buildStarRating(),
          SizedBox(height: 16.sH), // Reduced from 20
          _buildRatingLabel(),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return _buildSection(
      icon: Icons.feedback_outlined,
      iconColor: AppColor.gray900,
      title: 'What can we improve?',
      subtitle: 'Select categories that need attention',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 18.sH), // Reduced from 24
          _buildEnhancedChips(),
          SizedBox(height: 20.sH), // Reduced from 28
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final s = TextStyleHelper.instance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.sW), // Reduced from 20
        border: Border.all(color: AppColor.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray900.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          Responsive.isDesktop(context) ? 24.sW : 18.sW,
        ), // Reduced from 32/24
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.sW), // Reduced from 12
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      10.sW,
                    ), // Reduced from 12
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.sW,
                  ), // Reduced from 24
                ),
                SizedBox(width: 12.sW), // Reduced from 16
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: s.headline24MediumInter.copyWith(
                          color: AppColor.gray900,
                          fontSize: Responsive.responsiveFontSize(
                            context,
                            18,
                          ), // Reduced from 22
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.sH), // Reduced from 4
                      Text(
                        subtitle,
                        style: s.title16RegularInter.copyWith(
                          color: AppColor.gray600,
                          fontSize: Responsive.responsiveFontSize(
                            context,
                            12,
                          ), // Reduced from 14
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return SizedBox(
      height: _cachedStarSize + 12.sH, // Reduced from 16
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isSelected = index < _rating;
          return GestureDetector(
            onTap: () => _onStarTap(index + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(horizontal: 3.sW), // Reduced from 4
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                  CurvedAnimation(
                    parent: _starController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  size: _cachedStarSize,
                  color: isSelected ? AppColor.amber : AppColor.gray200,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onStarTap(int rating) {
    setState(() => _rating = rating);
    _starController.forward().then((_) => _starController.reverse());
  }

  Widget _buildRatingLabel() {
    final labels = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];
    final s = TextStyleHelper.instance;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_rating),
        padding: EdgeInsets.symmetric(
          horizontal: 16.sW,
          vertical: 8.sH,
        ), // Reduced from 20/10
        decoration: BoxDecoration(
          color: _getRatingColor(_rating).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.sW), // Reduced from 25
          border: Border.all(
            color: _getRatingColor(_rating).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          labels[_rating - 1],
          style: s.title16RegularInter.copyWith(
            color: _getRatingColor(_rating),
            fontWeight: FontWeight.w700,
            fontSize: Responsive.responsiveFontSize(
              context,
              12,
            ), // Reduced from 14
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return AppColor.red;
      case 3:
        return AppColor.amber;
      case 4:
      case 5:
        return AppColor.gray900;
      default:
        return AppColor.gray500;
    }
  }

  Widget _buildEnhancedChips() {
    if (Responsive.isMobile(context)) {
      return _buildMobileChipLayout();
    } else {
      return _buildGridChipLayout();
    }
  }

  Widget _buildMobileChipLayout() {
    final s = TextStyleHelper.instance;
    return Wrap(
      spacing: 8.sW, // Reduced from 10
      runSpacing: 10.sH, // Reduced from 14
      children: List.generate(widget.chips.length, (index) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _chipControllers[index],
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: FadeTransition(
            opacity: _chipControllers[index],
            child: _buildEnhancedChip(widget.chips[index], s),
          ),
        );
      }),
    );
  }

  Widget _buildGridChipLayout() {
    final s = TextStyleHelper.instance;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cachedChipColumns,
        crossAxisSpacing: 10.sW, // Reduced from 12
        mainAxisSpacing: 12.sH, // Reduced from 16
        childAspectRatio: Responsive.isDesktop(context) ? 3.0 : 2.5,
      ),
      itemCount: widget.chips.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _chipControllers[index],
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: FadeTransition(
            opacity: _chipControllers[index],
            child: _buildEnhancedChip(widget.chips[index], s),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedChip(String label, TextStyleHelper s) {
    final isSelected = _selected.contains(label);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleChip(label),
            borderRadius: BorderRadius.circular(24.sW), // Reduced from 30
            splashColor: AppColor.gray900.withOpacity(0.1),
            highlightColor: AppColor.gray900.withOpacity(0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isDesktop(context)
                    ? 16.sW
                    : 12.sW, // Reduced from 20/16
                vertical: Responsive.isDesktop(context)
                    ? 10.sH
                    : 8.sH, // Reduced from 14/12
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.gray900 : AppColor.gray50,
                borderRadius: BorderRadius.circular(24.sW), // Reduced from 30
                border: Border.all(
                  color: isSelected ? AppColor.gray900 : AppColor.gray200,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColor.gray900.withOpacity(0.15),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: s.title16RegularInter.copyWith(
                    color: isSelected ? AppColor.white : AppColor.gray700,
                    fontSize: Responsive.responsiveFontSize(
                      context,
                      Responsive.isDesktop(context)
                          ? 12
                          : 11, // Reduced from 14/13
                    ),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleChip(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  Widget _buildMessageInput() {
    final s = TextStyleHelper.instance;
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Additional Comments (Optional)',
          style: s.title16RegularInter.copyWith(
            color: AppColor.gray900,
            fontWeight: FontWeight.w700,
            fontSize: Responsive.responsiveFontSize(
              context,
              14,
            ), // Reduced from 16
          ),
        ),
        SizedBox(height: 8.sH), // Reduced from 12
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.sW), // Reduced from 16
            border: Border.all(color: AppColor.gray200, width: 1.5),
            color: AppColor.gray50,
          ),
          child: TextField(
            controller: _msgCtrl,
            maxLines: isDesktop
                ? 4 // Reduced from 5
                : Responsive.isTablet(context)
                ? 3 // Reduced from 4
                : 3,
            style: s.title16RegularInter.copyWith(
              color: AppColor.gray900,
              fontSize: Responsive.responsiveFontSize(
                context,
                13,
              ), // Reduced from 15
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Tell us more about your experience...',
              hintStyle: s.title16RegularInter.copyWith(
                color: AppColor.gray400,
                fontSize: Responsive.responsiveFontSize(
                  context,
                  13,
                ), // Reduced from 15
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.sW), // Reduced from 20
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final s = TextStyleHelper.instance;

    return SizedBox(
      width: double.infinity,
      height: _cachedButtonHeight,
      child: ElevatedButton(
        onPressed: _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.gray900,
          foregroundColor: AppColor.white,
          elevation: 3,
          shadowColor: AppColor.gray900.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sW), // Reduced from 16
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.sW), // Reduced from 32
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Submit Feedback',
              style: s.headline24MediumInter.copyWith(
                color: AppColor.white,
                fontSize: Responsive.responsiveFontSize(
                  context,
                  14,
                ), // Reduced from 16
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.sW), // Reduced from 12
            Icon(
              Icons.send_rounded,
              size: 16.sW,
              color: AppColor.white,
            ), // Reduced from 20
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    final msg = _msgCtrl.text.trim();

    if (msg.isEmpty && _selected.isEmpty) {
      _showSnackBar(
        'Please provide feedback or select categories.',
        AppColor.red,
      );
      return;
    }

    if (widget.onSubmit != null) {
      widget.onSubmit!(_rating, msg, _selected.toSet());
    } else {
      _showSnackBar(
        'Thank you for your feedback! Rating: $_rating stars',
        AppColor.gray900,
      );
    }

    // Reset form
    setState(() {
      _msgCtrl.clear();
      _selected.clear();
      _rating = widget.initialRating.clamp(1, 5);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyleHelper.instance.title16RegularInter.copyWith(
            color: AppColor.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.sW), // Reduced from 12
        ),
        margin: EdgeInsets.all(12.sW), // Reduced from 16
      ),
    );
  }
}
