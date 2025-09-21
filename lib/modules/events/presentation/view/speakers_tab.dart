import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/events/data/models/week_model.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/bottom_cta.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/month_selector.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/schedule_list.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/speaker_header.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/week_strip.dart';

import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import '../../../../core/resourses/style_manager.dart';

class SpeakersTabContent extends StatefulWidget {
  final String headerTitle;
  final String monthLabel;
  final DateTime currentMonth;
  final WeekModel week;
  final List<Speaker> speakers;
  final String ctaTitle;
  final String ctaSubtitle;
  final IconData ctaIcon;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final String userId;

  final Function(Speaker)? onSpeakerTap;

  const SpeakersTabContent({
    super.key,
    required this.headerTitle,
    required this.monthLabel,
    required this.currentMonth,
    required this.week,
    required this.speakers,
    required this.ctaTitle,
    required this.ctaSubtitle,
    this.ctaIcon = Icons.wb_sunny_outlined,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onSpeakerTap,
    required this.userId,
  });

  @override
  State<SpeakersTabContent> createState() => _SpeakersTabContentState();
}

class _SpeakersTabContentState extends State<SpeakersTabContent> {
  // 30-day window starting from the first day of currentMonth (UTC at 00:00)
  late DateTime _windowStartUtc;
  static const int _windowDays = 30;

  // Index of the first day of the current 7-day slice inside the 30-day array
  int _sliceStart = 0; // 0..(30-7)=23
  static const int _sliceLen = 7;

  // Which day is selected within the current 7-day slice (0..6)
  int _selectedIndexInSlice = 0;

  // Precomputed 30 dates (UTC) for the window
  late List<DateTime> _days30;

  @override
  void initState() {
    super.initState();
    _resetWindowFromMonth(widget.currentMonth);
  }

  @override
  void didUpdateWidget(covariant SpeakersTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent changes the month, rebuild our window & reset slice/selection
    if (oldWidget.currentMonth.year != widget.currentMonth.year ||
        oldWidget.currentMonth.month != widget.currentMonth.month) {
      _resetWindowFromMonth(widget.currentMonth);
    }
  }

  void _resetWindowFromMonth(DateTime monthAnchorLocal) {
    // seed = first day of this month, in UTC
    final firstDayLocal = DateTime(
      monthAnchorLocal.year,
      monthAnchorLocal.month,
      1,
    );
    _windowStartUtc = DateTime.utc(
      firstDayLocal.year,
      firstDayLocal.month,
      firstDayLocal.day,
    );
    _days30 = List.generate(
      _windowDays,
      (i) => _windowStartUtc.add(Duration(days: i)),
    );
    _sliceStart = 0;
    _selectedIndexInSlice = 0;
    setState(() {});
  }

  // Slice navigation
  void _prev7Days() {
    if (_sliceStart == 0) return;
    setState(() {
      _sliceStart = (_sliceStart - _sliceLen).clamp(0, _windowDays - _sliceLen);
      _selectedIndexInSlice = 0; // reset selection to first visible day
    });
  }

  void _next7Days() {
    if (_sliceStart >= _windowDays - _sliceLen) return;
    setState(() {
      _sliceStart = (_sliceStart + _sliceLen).clamp(0, _windowDays - _sliceLen);
      _selectedIndexInSlice = 0; // reset selection to first visible day
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Build the current 7-day slice
    final slice = _days30.sublist(_sliceStart, _sliceStart + _sliceLen);

    // Build a WeekModel from the slice for the WeekStrip
    final week = WeekModel(
      weekdays: slice.map((d) => _weekdayShort(d)).toList(growable: false),
      dates: slice.map((d) => d.day).toList(growable: false),
      selectedIndex: _selectedIndexInSlice,
    );

    // Selected day exact UTC range
    final selectedDay = slice[_selectedIndexInSlice];
    final dayStart = DateTime.utc(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final dayEnd = DateTime.utc(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      23,
      59,
      59,
      999,
    );

    // Filter speakers to selected day, sort by startAt
    final daySpeakers = widget.speakers.where((sp) {
      final t = sp.startAt; // UTC instant in your model
      return !t.isBefore(dayStart) && !t.isAfter(dayEnd);
    }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(slice, week, daySpeakers)
            : _buildMobileTabletLayout(slice, week, daySpeakers, isMobile),
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<DateTime> slice,
    WeekModel week,
    List<Speaker> daySpeakers,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            SpeakersHeader(title: widget.headerTitle, isDesktop: true),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left sidebar with controls
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      MonthSelector(
                        monthLabel: widget.monthLabel,
                        onPrev: widget.onPrevMonth,
                        onNext: widget.onNextMonth,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 24),
                      _SliceHeader(
                        start: slice.first,
                        end: slice.last,
                        onPrev7: (_sliceStart == 0) ? null : _prev7Days,
                        onNext7: (_sliceStart >= _windowDays - _sliceLen)
                            ? null
                            : _next7Days,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 16),
                      WeekStrip(
                        week: week,
                        selectedIndex: _selectedIndexInSlice,
                        onDaySelected: (i) =>
                            setState(() => _selectedIndexInSlice = i),
                        isDesktop: true,
                      ),
                      const SizedBox(height: 24),
                      BottomCta(
                        title: widget.ctaTitle,
                        subtitle: widget.ctaSubtitle,
                        icon: widget.ctaIcon,
                        isDesktop: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 15.sW),

                // Right content area
                Expanded(
                  child: ScheduleList(
                    speakers: daySpeakers,
                    userId: widget.userId,
                    onTap: (index) {
                      if (widget.onSpeakerTap != null &&
                          index < daySpeakers.length) {
                        widget.onSpeakerTap!(daySpeakers[index]);
                      }
                    },
                    isDesktop: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabletLayout(
    List<DateTime> slice,
    WeekModel week,
    List<Speaker> daySpeakers,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //   const SizedBox(height: 10),
          SpeakersHeader(title: widget.headerTitle, isDesktop: false),
          SizedBox(height: 20.sH),

          // Month controls
          MonthSelector(
            monthLabel: widget.monthLabel,
            onPrev: widget.onPrevMonth,
            onNext: widget.onNextMonth,
            isDesktop: false,
          ),

          SizedBox(height: 16.sH),

          // 7-day strip + slice navigation buttons
          _SliceHeader(
            start: slice.first,
            end: slice.last,
            onPrev7: (_sliceStart == 0) ? null : _prev7Days,
            onNext7: (_sliceStart >= _windowDays - _sliceLen)
                ? null
                : _next7Days,
            isDesktop: false,
          ),
          SizedBox(height: 10.sH),
          WeekStrip(
            week: week,
            selectedIndex: _selectedIndexInSlice,
            onDaySelected: (i) => setState(() => _selectedIndexInSlice = i),
            isDesktop: false,
          ),
          SizedBox(height: 24.sH),

          // Schedule list for the selected day
          Center(
            child: ScheduleList(
              speakers: daySpeakers,
              userId: widget.userId,

              onTap: (index) {
                if (widget.onSpeakerTap != null && index < daySpeakers.length) {
                  widget.onSpeakerTap!(daySpeakers[index]);
                }
              },
              isDesktop: false,
            ),
          ),

          const SizedBox(height: 24),
          BottomCta(
            title: widget.ctaTitle,
            subtitle: widget.ctaSubtitle,
            icon: widget.ctaIcon,
            isDesktop: false,
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColor.grey200),
        ],
      ),
    );
  }

  String _weekdayShort(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}

class _SliceHeader extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback? onPrev7;
  final VoidCallback? onNext7;
  final bool isDesktop;

  const _SliceHeader({
    required this.start,
    required this.end,
    this.onPrev7,
    this.onNext7,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final label = _rangeLabel(start, end);

    if (isDesktop) {
      return Row(
        children: [
          Text(
            label,
            style: TextStyleHelper.instance.title16BoldInter.copyWith(
              color: AppColor.gray900,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrev7,
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 16,
                      color: AppColor.blueGray100,
                    ),
                    label: Text(
                      'Prev 7',
                      style: TextStyleHelper.instance.body14RegularInter,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      side: BorderSide(color: AppColor.blueGray100),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNext7,
                    icon: const Icon(Icons.chevron_right, size: 16),
                    label: Text(
                      'Next 7',
                      style: TextStyleHelper.instance.body14RegularInter,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      side: BorderSide(color: AppColor.blueGray100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // space between label & buttons
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev7,
                  icon: const Icon(Icons.chevron_left, size: 16),
                  label: Text(
                    'Prev 7',
                    style: TextStyleHelper.instance.body14RegularInter,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: BorderSide(color: AppColor.blueGray100),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNext7,
                  icon: const Icon(Icons.chevron_right, size: 16),
                  label: Text(
                    'Next 7',
                    style: TextStyleHelper.instance.body14RegularInter,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: BorderSide(color: AppColor.blueGray100),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.sH),
        Text(
          label,
          style: TextStyleHelper.instance.title14BoldInter.copyWith(
            color: AppColor.gray900,
          ),
        ),
      ],
    );
  }

  String _rangeLabel(DateTime a, DateTime b) {
    String m(int x) => const [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ][x - 1];
    if (a.month == b.month && a.year == b.year) {
      return "${m(a.month)} ${a.day}–${b.day}, ${a.year}";
    }
    return "${m(a.month)} ${a.day}, ${a.year} – ${m(b.month)} ${b.day}, ${b.year}";
  }
}
