import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WeekStrip extends StatefulWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  final List<DateTime> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.days.length != widget.days.length) {
      _scrollToSelected(animated: true);
    }
  }

  void _scrollToSelected({required bool animated}) {
    if (!_controller.hasClients) return;
    const itemWidth = 72.0;
    final target = (widget.selectedIndex * itemWidth) - (itemWidth * 1.5);
    final clamped = target.clamp(0.0, _controller.position.maxScrollExtent);

    if (animated) {
      _controller.animateTo(
        clamped,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(clamped);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ProgramsLayout.spacingSmall(context);
    final localeName = context.locale.toLanguageTag();

    return SizedBox(
      height: ProgramsLayout.size(context, 125),
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spacing),
        itemCount: widget.days.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final day = widget.days[index];
          final isSelected = index == widget.selectedIndex;
          return _DayPill(
            dayLabel: DateFormat('E', localeName).format(day),
            dayNumber: day.day.toString(),
            selected: isSelected,
            onTap: () => widget.onDaySelected(index),
          );
        },
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.dayLabel,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String dayLabel;
  final String dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColor.black : AppColor.white;
    final textColor = selected ? AppColor.white : AppColor.gray500;
    final size = ProgramsLayout.size(context, 80);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: ProgramsLayout.size(context, 110),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
          border: Border.all(
            color: selected ? Colors.transparent : AppColor.blueGray100,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              dayLabel,
              style: ProgramsTypography.bodyPrimary(
                context,
              ).copyWith(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: ProgramsTypography.bodyPrimary(
                context,
              ).copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
