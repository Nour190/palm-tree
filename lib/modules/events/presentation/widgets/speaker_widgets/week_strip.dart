import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import '../../../../../core/resourses/style_manager.dart';

class WeekStrip extends StatefulWidget {
  // CHANGED API: now takes all month days instead of a 7-day model.
  final List<DateTime> days;   // local month days
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;
  final bool isDesktop;

  const WeekStrip({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.isDesktop,
  });

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  final _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(false));
  }

  @override
  void didUpdateWidget(covariant WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.days.first.month != widget.days.first.month ||
        oldWidget.days.length != widget.days.length) {
      _scrollToSelected(true);
    }
  }

  void _scrollToSelected(bool animated) {
    if (!mounted || !_ctrl.hasClients) return;
    const itemWidth = 72.0; // chip + gap approximation
    final target = (widget.selectedIndex * itemWidth) - (itemWidth * 1.5);
    final clamped = target.clamp(0.0, _ctrl.position.maxScrollExtent);
    if (animated) {
      _ctrl.animateTo(clamped, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    } else {
      _ctrl.jumpTo(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.days.length,
        padding: EdgeInsets.symmetric(horizontal: 2.sH),
        separatorBuilder: (_, __) => SizedBox(width: 6.sW),
        itemBuilder: (context, i) {
          final d = widget.days[i];
          final selected = i == widget.selectedIndex;
          final dow = DateFormat('E').format(d); // Mon, Tue, Wed...

          return _DayPill(
            top: dow,
            bottom: d.day.toString(),
            selected: selected,
            onTap: () => widget.onDaySelected(i),
          );
        },
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String top;
  final String bottom;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({
    required this.top,
    required this.bottom,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg   = selected ? AppColor.black : AppColor.transparent;
    final text = selected ? AppColor.white : AppColor.gray400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 64,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              top,
              style: (selected
                      ? TextStyleHelper.instance.title14BoldInter
                      : TextStyleHelper.instance.title14BlackRegularInter)
                  .copyWith(color: text),
            ),
            const SizedBox(height: 2),
            Text(
              bottom,
              style: (selected
                      ? TextStyleHelper.instance.title14BoldInter
                      : TextStyleHelper.instance.title14BlackRegularInter)
                  .copyWith(color: text),
            ),
          ],
        ),
      ),
    );
  }
}
