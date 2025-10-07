// lib/modules/artist_details/presentation/view/tabs/feedback_tab.dart
import 'package:baseqat/core/components/alerts/custom_snackbar.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({
    super.key,
    this.chips = const [
      'feedback_chip_over_service',
      'feedback_chip_product',
      'feedback_chip_artist_support',
      'feedback_chip_quality',
      'feedback_chip_accessibility',
      'feedback_chip_clear_information',
      'feedback_chip_artwork_story',
      'feedback_chip_material_uniqueness',
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

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _chipControllers = List.generate(
      widget.chips.length,
          (index) => AnimationController(
        duration: Duration(milliseconds: 150 + (index * 30)),
        vsync: this,
      ),
    );

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
        _cachedStarSize = 32.sW;
        _cachedMaxWidth = 500.sW;
        _cachedChipColumns = screenWidth > 1200 ? 4 : 3;
        _cachedButtonHeight = 56.sH;
        break;
      case DeviceType.tablet:
        _cachedStarSize = 28.sW;
        _cachedMaxWidth = 450.sW;
        _cachedChipColumns = 3;
        _cachedButtonHeight = 52.sH;
        break;
      case DeviceType.mobile:
        _cachedStarSize = 28.sW;
        _cachedMaxWidth = double.infinity;
        _cachedChipColumns = 2;
        _cachedButtonHeight = 50.sH;
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
                    _buildRatingSection(),
                    SizedBox(height: 20.sH),
                    _buildFeedbackSection(),
                    SizedBox(height: 24.sH),
                    _buildSubmitButton(),
                    if (Responsive.isMobile(context))
                      SizedBox(height: 40.sH),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    final s = TextStyleHelper.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'feedback_rate_experience'.tr(),
          style: s.headline24MediumInter.copyWith(
            color: Colors.black,
            fontSize: Responsive.responsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 6.sH),
        Text(
          'feedback_are_you_satisfied'.tr(),
          style: s.title16RegularInter.copyWith(
            color: AppColor.gray600,
            fontSize: Responsive.responsiveFontSize(context, 13),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.sH),
        _buildStarRating(),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    final s = TextStyleHelper.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'feedback_improvement'.tr(),
          style: s.headline24MediumInter.copyWith(
            color: Colors.black,
            fontSize: Responsive.responsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16.sH),
        _buildEnhancedChips(),
        SizedBox(height: 20.sH),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final isSelected = index < _rating;
        return GestureDetector(
          onTap: () => _onStarTap(index + 1),
          child: Padding(
            padding: EdgeInsets.only(right: 4.sW),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: _cachedStarSize,
              color: isSelected ? Colors.black : AppColor.gray200,
            ),
          ),
        );
      }),
    );
  }

  void _onStarTap(int rating) {
    setState(() => _rating = rating);
    _starController.forward().then((_) => _starController.reverse());
  }

  Widget _buildEnhancedChips() {
    final s = TextStyleHelper.instance;
    return Wrap(
      spacing: 8.sW,
      runSpacing: 10.sH,
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
            child: _buildChoiceChip(widget.chips[index].tr(), s),
          ),
        );
      }),
    );
  }

  Widget _buildChoiceChip(String label, TextStyleHelper s) {
    final isSelected = _selected.contains(label);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _toggleChip(label),
      labelStyle: s.title16RegularInter.copyWith(
        color: isSelected ? AppColor.white : AppColor.gray700,
        fontSize: Responsive.responsiveFontSize(context, 13),
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColor.gray100,
      selectedColor: Colors.black,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.sW),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.sW,
        vertical: 8.sH,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 4.sW),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      pressElevation: 0,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sW),
        border: Border.all(color: AppColor.gray200.withOpacity(0.5), width: 1),
        color: AppColor.gray50,
      ),
      child: TextField(
        controller: _msgCtrl,
        maxLines: isDesktop ? 4 : 4,
        style: s.title16RegularInter.copyWith(
          color: AppColor.gray900,
          fontSize: Responsive.responsiveFontSize(context, 14),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'feedback_hint'.tr(),
          hintStyle: s.title16RegularInter.copyWith(
            color: AppColor.gray400,
            fontSize: Responsive.responsiveFontSize(context, 14),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.sW),
        ),
      ),
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
          backgroundColor: Colors.black,
          foregroundColor: AppColor.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sW),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'feedback_submit'.tr(),
          style: s.headline24MediumInter.copyWith(
            color: AppColor.white,
            fontSize: Responsive.responsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final msg = _msgCtrl.text.trim();

    if (msg.isEmpty && _selected.isEmpty) {
      _showSnackBar(
        'feedback_error_empty'.tr(),
        AppColor.red,
      );
      return;
    }

    if (widget.onSubmit != null) {
      widget.onSubmit!(_rating, msg, _selected.toSet());
    } else {
      _showSnackBar(
        'feedback_thank_you'.tr(args: ['$_rating']),
        AppColor.gray900,
      );
    }

    setState(() {
      _msgCtrl.clear();
      _selected.clear();
      _rating = widget.initialRating.clamp(1, 5);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (backgroundColor == AppColor.red) {
      context.showErrorSnackBar(message);
    } else {
      context.showSuccessSnackBar(message);
    }
  }
}
