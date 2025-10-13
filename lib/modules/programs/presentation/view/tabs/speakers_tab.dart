import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/view/more_details_views_tabs/workshop_info_view.dart';
import 'package:baseqat/modules/programs/presentation/view/tabs/workshops_tab.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/bottom_cta.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/month_selector.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/schedule_list.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/schedule_tabs.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/speaker_header.dart';
import 'package:baseqat/modules/programs/presentation/widgets/speaker_widgets/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Combined tab showing both Speakers and Workshops with same UI
class SpeakersWorkshopsTabContent extends StatefulWidget {
  const SpeakersWorkshopsTabContent({
    super.key,
    required this.headerTitle,
    required this.monthLabel,
    required this.currentMonth,
    required this.speakers,
    required this.workshops,
    required this.languageCode,
    required this.ctaTitle,
    required this.ctaSubtitle,
    this.ctaIcon = Icons.wb_sunny_outlined,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onSpeakerTap,
    this.onWorkshopTap,
  });

  final String headerTitle;
  final String monthLabel;
  final DateTime currentMonth;
  final List<Speaker> speakers;
  final List<Workshop> workshops;
  final String languageCode;
  final String ctaTitle;
  final String ctaSubtitle;
  final IconData ctaIcon;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<Speaker>? onSpeakerTap;
  final ValueChanged<Workshop>? onWorkshopTap;

  @override
  State<SpeakersWorkshopsTabContent> createState() =>
      _SpeakersWorkshopsTabContentState();
}

class _SpeakersWorkshopsTabContentState
    extends State<SpeakersWorkshopsTabContent> {
  late List<DateTime> _daysInMonth;
  int _selectedDayIndex = 0;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _buildDays(widget.currentMonth);
  }

  @override
  void didUpdateWidget(covariant SpeakersWorkshopsTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth.year != widget.currentMonth.year ||
        oldWidget.currentMonth.month != widget.currentMonth.month) {
      _buildDays(widget.currentMonth);
    }
  }

  void _buildDays(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    _daysInMonth = List.generate(
      last.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );

    final today = DateTime.now();
    if (today.year == month.year && today.month == month.month) {
      final match = _daysInMonth.indexWhere((d) => d.day == today.day);
      _selectedDayIndex = match >= 0 ? match : 0;
    } else {
      _selectedDayIndex = 0;
    }
  }

  List<Speaker> _speakersForSelectedDay() {
    if (_daysInMonth.isEmpty) return const [];
    final selectedDay = _daysInMonth[_selectedDayIndex];
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final end = start.add(const Duration(days: 1));

    final sessions = widget.speakers.where((s) {
      final st = s.startAt.toLocal();
      return !st.isBefore(start) && st.isBefore(end);
    }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

    return sessions;
  }

  List<Workshop> _workshopsForSelectedDay() {
    if (_daysInMonth.isEmpty) return const [];
    final selectedDay = _daysInMonth[_selectedDayIndex];
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final end = start.add(const Duration(days: 1));

    final sessions = widget.workshops.where((w) {
      final st = w.startAt.toLocal();
      return !st.isBefore(start) && st.isBefore(end);
    }).toList()..sort((a, b) => a.startAt.compareTo(b.startAt));

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    final padding = ProgramsLayout.pagePadding(context);
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final spacingMedium = ProgramsLayout.spacingMedium(context);
    final tabs = [
      'programs.schedule.tabs.speakers'.tr(),
      'programs.schedule.tabs.workshops'.tr(),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpeakersHeader(title: widget.headerTitle),
          SizedBox(height: spacingLarge),
          MonthSelector(
            monthLabel: widget.monthLabel,
            onPrev: widget.onPrevMonth,
            onNext: widget.onNextMonth,
          ),
          SizedBox(height: spacingLarge),
          WeekStrip(
            days: _daysInMonth,
            selectedIndex: _selectedDayIndex,
            onDaySelected: (i) => setState(() => _selectedDayIndex = i),
          ),
          SizedBox(height: spacingLarge),
          ScheduleTabs(
            tabs: tabs,
            index: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          SizedBox(height: spacingLarge),
          _tabIndex == 0
              ? _SpeakersSection(
                  speakers: _speakersForSelectedDay(),
                  languageCode: widget.languageCode,
                  onSpeakerTap: widget.onSpeakerTap,
                )
              : _WorkshopsSection(
                  workshops: _workshopsForSelectedDay(),
                  languageCode: widget.languageCode,
                  onWorkshopTap: widget.onWorkshopTap,
                ),
          SizedBox(height: spacingLarge),
          const Divider(color: AppColor.blueGray100),
          SizedBox(height: spacingMedium),
          BottomCta(
            title: widget.ctaTitle,
            subtitle: widget.ctaSubtitle,
            icon: widget.ctaIcon,
          ),
        ],
      ),
    );
  }
}

class _SpeakersSection extends StatelessWidget {
  const _SpeakersSection({
    required this.speakers,
    required this.languageCode,
    this.onSpeakerTap,
  });

  final List<Speaker> speakers;
  final String languageCode;
  final ValueChanged<Speaker>? onSpeakerTap;

  @override
  Widget build(BuildContext context) {
    if (speakers.isEmpty) {
      return _EmptyState(
        message: 'programs.schedule.speakers_empty'.tr(),
        icon: Icons.event_busy_outlined,
      );
    }

    return Column(
      children: [
        ScheduleList(
          speakers: speakers,
          userId: "",
          onSpeakerTap: onSpeakerTap,
        ),
        SizedBox(height: ProgramsLayout.spacingLarge(context)),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            DateFormat.yMMMMd(
              context.locale.toLanguageTag(),
            ).format(speakers.first.startAt.toLocal()),
            style: ProgramsTypography.bodySecondary(
              context,
            ).copyWith(color: AppColor.gray500),
          ),
        ),
      ],
    );
  }
}

class _WorkshopsSection extends StatelessWidget {
  const _WorkshopsSection({
    required this.workshops,
    required this.languageCode,
    this.onWorkshopTap,
  });

  final List<Workshop> workshops;
  final String languageCode;
  final ValueChanged<Workshop>? onWorkshopTap;

  @override
  Widget build(BuildContext context) {
    if (workshops.isEmpty) {
      return _EmptyState(
        message: 'programs.schedule.workshops_empty'.tr(),
        icon: Icons.work_off_outlined,
      );
    }

    return Column(
      children: [
        WorkshopList(
          workshops: workshops,
          languageCode: languageCode,
          onWorkshopTap: (workshop) {
            navigateTo(context, WorkshopInfoScreen(workshop: workshop , userId: ""));
          },
        ),
        SizedBox(height: ProgramsLayout.spacingLarge(context)),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            DateFormat.yMMMMd(
              context.locale.toLanguageTag(),
            ).format(workshops.first.startAt.toLocal()),
            style: ProgramsTypography.bodySecondary(
              context,
            ).copyWith(color: AppColor.gray500),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ProgramsLayout.sectionPadding(context),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(ProgramsLayout.radius20(context)),
        border: Border.all(color: AppColor.blueGray100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ProgramsLayout.size(context, 48),
            color: AppColor.gray400,
          ),
          SizedBox(height: ProgramsLayout.spacingMedium(context)),
          Text(
            message,
            style: ProgramsTypography.bodySecondary(
              context,
            ).copyWith(color: AppColor.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
