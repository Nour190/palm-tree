// lib/modules/artist_details/presentation/view/tabs/feedback_tab.dart
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

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

  /// Available tag chips
  final List<String> chips;

  /// Initial star rating (1..5)
  final int initialRating;

  /// Prefilled message
  final String initialMessage;

  /// Pre-selected tags
  final Set<String> preselected;

  /// Callback when user taps Submit
  /// Provides: (rating, message, tags)
  final void Function(int rating, String message, Set<String> tags)? onSubmit;

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  late int _rating = widget.initialRating.clamp(1, 5);
  late final TextEditingController _msgCtrl = TextEditingController(
    text: widget.initialMessage,
  );
  late final Set<String> _selected = {...widget.preselected};

  bool get _isDesktop => SizeUtils.width >= 1200;
  bool get _isTablet => SizeUtils.width >= 840 && SizeUtils.width < 1200;

  double get _starSizePx => _isDesktop ? 56 : (_isTablet ? 48 : 40);
  double get _chipVPadPx => _isDesktop ? 10 : (_isTablet ? 10 : 8);
  double get _chipHPadPx => _isDesktop ? 24 : (_isTablet ? 20 : 16);

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;
    final starSize = _starSizePx.h;

    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Rate Section =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.h),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColor.blueGray100, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate Your Experience',
                    style: s.display48BoldInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Are you satisfied with the service?',
                    style: s.title16RegularInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildStarRow(
                    starSize: starSize,
                    rating: _rating,
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ================= Feedback Section =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us what can be improved',
                    style: s.headline24MediumInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Chips (tags)
                  _buildChipWrap(
                    labels: widget.chips,
                    selected: _selected,
                    chipHPadPx: _chipHPadPx,
                    chipVPadPx: _chipVPadPx,
                    onToggle: (label, value) {
                      setState(() {
                        if (value) {
                          _selected.add(label);
                        } else {
                          _selected.remove(label);
                        }
                      });
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Message box
                  _buildMessageField(controller: _msgCtrl, isTablet: _isTablet),

                  SizedBox(height: 16.h),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 80.h,
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.gray900,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.h),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.h,
                          vertical: 16.h,
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: s.headline32MediumInter.copyWith(
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ========================= Private Builders ========================= */

  Widget _buildStarRow({
    required double starSize,
    required int rating, // 1..5
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: starSize,
      child: Row(
        children: List.generate(5, (i) {
          final filled = i < rating;
          return Padding(
            padding: EdgeInsets.only(right: i == 4 ? 0 : 10.h),
            child: InkResponse(
              onTap: () => onChanged(i + 1),
              radius: (starSize / 2) + 8.h,
              child: SizedBox(
                width: starSize,
                height: starSize,
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: starSize,
                  color: AppColor.gray900,
                  semanticLabel: 'Rate ${i + 1} star${i == 0 ? "" : "s"}',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChipWrap({
    required List<String> labels,
    required Set<String> selected,
    required double chipHPadPx,
    required double chipVPadPx,
    required void Function(String, bool) onToggle,
  }) {
    final s = TextStyleHelper.instance;
    return Wrap(
      spacing: 8.h,
      runSpacing: 8.h,
      children: List<Widget>.generate(labels.length, (idx) {
        final label = labels[idx];
        final isSel = selected.contains(label);
        return ChoiceChip(
          label: Text(
            label,
            style: s.title16RegularInter.copyWith(color: AppColor.white),
          ),
          selected: isSel,
          onSelected: (v) => onToggle(label, v),
          backgroundColor: AppColor.gray400,
          selectedColor: AppColor.gray900,
          side: const BorderSide(color: AppColor.gray400, width: 1),
          padding: EdgeInsets.symmetric(
            horizontal: chipHPadPx.h,
            vertical: chipVPadPx.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.h),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }),
    );
  }

  Widget _buildMessageField({
    required TextEditingController controller,
    required bool isTablet,
  }) {
    final s = TextStyleHelper.instance;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: (isTablet ? 332 : 280).h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: AppColor.backgroundGray, // #F0F0F0
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(color: AppColor.gray400, width: 1),
      ),
      child: TextField(
        controller: controller,
        minLines: isTablet ? 8 : 6,
        maxLines: null,
        style: s.title16RegularInter.copyWith(color: AppColor.gray900),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'Tell us how we can improve...',
          hintStyle: s.headline24MediumInter.copyWith(color: AppColor.gray400),
        ),
      ),
    );
  }

  /* ============================ Actions ============================ */

  void _onSubmit() {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a short message.')),
      );
      return;
    }

    // Forward to parent (rating, message, tags) or fallback toast
    if (widget.onSubmit != null) {
      widget.onSubmit!(_rating, msg, _selected.toSet());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thanks! Rating: $_rating • Tags: ${_selected.join(", ")}',
          ),
        ),
      );
    }

    // Reset UI quickly; keep rating consistent with initial value.
    setState(() {
      _msgCtrl.clear();
      _selected.clear();
      _rating = widget.initialRating.clamp(1, 5);
    });
  }
}
