import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/events/presentation/view/more_details_views_tabs/speakers_info_view.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/bottom_cta.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/month_selector.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/schedule_list.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/schedule_tabs.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/speaker_header.dart';
import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/week_strip.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';

/// -------------------------
/// SpeakersTabContent (page)
/// -------------------------
class SpeakersTabContent extends StatefulWidget {
  final String headerTitle;
  final String monthLabel;
  final DateTime currentMonth;
  final dynamic week; // kept for compatibility
  final List<Speaker> speakers; // startAt in UTC
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
  late List<DateTime> _daysInMonth;
  int _selectedIndex = 0; // in _daysInMonth
  int _tabIndex = 0; // 0 = Speakers, 1 = Workshop

  @override
  void initState() {
    super.initState();
    _rebuildMonth(widget.currentMonth);
  }

  @override
  void didUpdateWidget(covariant SpeakersTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth.year != widget.currentMonth.year ||
        oldWidget.currentMonth.month != widget.currentMonth.month) {
      _rebuildMonth(widget.currentMonth);
    }
  }

  void _rebuildMonth(DateTime month) {
    _daysInMonth = _buildMonthDays(month);
    _selectedIndex = _initialSelectedIndex(_daysInMonth, month);
    setState(() {});
  }

  // All local days of the month
  List<DateTime> _buildMonthDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(first.year, first.month, i + 1));
  }

  // Preselect today if it's in the current month, else day 1
  int _initialSelectedIndex(List<DateTime> days, DateTime month) {
    final now = DateTime.now();
    if (now.year != month.year || now.month != month.month) return 0;
    final today = DateTime(now.year, now.month, now.day);
    final idx = days.indexWhere((d) => d.year == today.year && d.month == today.month && d.day == today.day);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Pick selected day and filter sessions by UTC day-range
    final selectedDay = _daysInMonth[_selectedIndex];
    final dayStartUtc = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayEndUtc = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59, 999);

    final daySpeakers = widget.speakers
        .where((sp) => !sp.startAt.isBefore(dayStartUtc) && !sp.startAt.isAfter(dayEndUtc))
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpeakersHeader(title: widget.headerTitle, isDesktop: isDesktop),
                  SizedBox(height: isDesktop ? 24 : 16),

                  MonthSelector(
                    monthLabel: widget.monthLabel,
                    onPrev: widget.onPrevMonth,
                    onNext: widget.onNextMonth,
                    isDesktop: isDesktop,
                  ),
                  SizedBox(height: isDesktop ? 14 : 12),

                  // Full-month strip (horizontal scroll)
                  WeekStrip(
                    days: _daysInMonth,
                    selectedIndex: _selectedIndex,
                    onDaySelected: (i) => setState(() => _selectedIndex = i),
                    isDesktop: isDesktop,
                  ),
                  SizedBox(height: isDesktop ? 20 : 18),

                  ScheduleTabs(
                    tabs: const ['Speakers', 'Workshop'],
                    index: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                  ),
                  SizedBox(height: isDesktop ? 14 : 8),

                  // CONTENT
                  if (_tabIndex == 0)
                    ScheduleList(
                      speakers: daySpeakers,
                      userId: widget.userId,
                      isDesktop: isDesktop,
                    )
                  else
                    WorkshopList(
                      workshops: daySpeakers, // reuse filtered list (or swap to a dedicated workshops list)
                      userId: widget.userId,
                      isDesktop: isDesktop,
                    ),

                  SizedBox(height: isDesktop ? 28 : 20),
                  BottomCta(
                    title: widget.ctaTitle,
                    subtitle: widget.ctaSubtitle,
                    icon: widget.ctaIcon,
                    isDesktop: isDesktop,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: AppColor.grey200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------------
/// WorkshopList
/// -------------------------
class WorkshopList extends StatelessWidget {
  final List<Speaker> workshops; // sessions for the selected day
  final String userId;
  final bool isDesktop;

  const WorkshopList({
    super.key,
    required this.workshops,
    required this.userId,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (workshops.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(color: AppColor.blueGray100),
        ),
        child: const Text('No workshops for this day.'),
      );
    }

    // Parent is a SingleChildScrollView, so we keep a simple Column (no ListView/Expanded).
    return Column(
      children: List.generate(workshops.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == workshops.length - 1 ? 0 : 12.sH),
          child: WorkshopCard(
            speaker: workshops[i],
            userId: userId,
            index: i,
            isDesktop: isDesktop,
          ),
        );
      }),
    );
  }
}

/// -------------------------
/// WorkshopCard
/// -------------------------
class WorkshopCard extends StatelessWidget {
  final Speaker speaker;
  final String userId;
  final int index;
  final bool isDesktop;

  const WorkshopCard({
    super.key,
    required this.speaker,
    required this.userId,
    required this.index,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    const bandWidth = 30.0;
    final imageW = isDesktop ? 120.0 : 110.0;
    final imageH = isDesktop ? 82.0 : 76.0;

    // Keep "first is Live" behavior to match the mock; prefer isLive flag if present.
    final isLive = (speaker.isLive == true) || index == 0;
    final timeRange = _timeRange(speaker.startAt, speaker.endAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => navigateTo(context, SpeakersInfoScreen(speaker: speaker, userId: userId)),
        child: IntrinsicHeight( // guarantees finite height for stretch/hit testing
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left vertical band
              Container(
                width: bandWidth,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      isLive ? 'Live Now' : timeRange,
                      style: TextStyleHelper.instance.body12MediumInter
                          .copyWith(color: Colors.white, letterSpacing: .3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.sW),

              // White Card
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 110), // ensures tappable area
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.blueGray100, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 14 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: imageW,
                            height: imageH,
                            child: _buildCover(),
                          ),
                        ),
                        SizedBox(width: 12.sW),

                        // Title + description + presenter row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                _safeTitle(),
                                style: TextStyleHelper.instance.title16BoldInter
                                    .copyWith(color: AppColor.black),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6.sH),

                              // Description
                              Text(
                                _safeDescription(),
                                style: TextStyleHelper.instance.body12MediumInter
                                    .copyWith(color: AppColor.gray600, height: 1.35),
                                maxLines: isDesktop ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 10.sH),

                              // Presenter + Arrow
                              Row(
                                children: [
                                  // Avatar
                                  ClipOval(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: _buildAvatar(),
                                    ),
                                  ),
                                  SizedBox(width: 8.sW),

                                  // Name + role
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _presenter(),
                                          style: TextStyleHelper.instance.body12MediumInter
                                              .copyWith(color: AppColor.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Artist',
                                          style: TextStyleHelper.instance.caption12RegularInter
                                              .copyWith(color: AppColor.gray500),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // NE arrow
                                  _CircleIconButton(
                                    icon: Icons.north_east_rounded,
                                    size: 36,
                                    iconSize: 18,
                                    bgColor: Colors.white,
                                    borderColor: AppColor.blueGray100,
                                    iconColor: AppColor.gray700,
                                    onTap: () => navigateTo(
                                      context,
                                      SpeakersInfoScreen(speaker: speaker, userId: userId),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  String _safeTitle() =>
      (speaker.topicName?.trim().isNotEmpty ?? false)
          ? speaker.topicName!.trim()
          : (speaker.name ?? 'Workshop');

  String _safeDescription() =>
      (speaker.topicDescription?.trim().isNotEmpty ?? false)
          ? speaker.topicDescription!.trim()
          : (speaker.bio ?? '');

  String _presenter() =>
      (speaker.name?.trim().isNotEmpty ?? false)
          ? speaker.name!.trim()
          : (speaker.name ?? 'Speaker');

  String _timeRange(DateTime startUtc, DateTime? endUtc) {
    final f = DateFormat.jm();
    final a = f.format(startUtc.toLocal());
    final b = endUtc == null ? null : f.format(endUtc.toLocal());
    return b == null ? a : '$a – $b'; // en dash
  }

  Widget _buildCover() {
    final url = _pickFirst([
      (speaker.gallery != null && speaker.gallery!.isNotEmpty) ? speaker.gallery!.first : null,
      speaker.gallery[0],

    ]);
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColor.gray100,
        child: Icon(Icons.image_rounded, color: AppColor.gray400, size: 28),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColor.gray100,
        child: Icon(Icons.image_rounded, color: AppColor.gray400, size: 28),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = _pickFirst([
      speaker.profileImage,
      (speaker.gallery != null && speaker.gallery!.isNotEmpty) ? speaker.gallery!.first : null,
    ]);
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColor.gray100,
        child: Icon(Icons.person_rounded, color: AppColor.gray400, size: 18),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColor.gray100,
        child: Icon(Icons.person_rounded, color: AppColor.gray400, size: 18),
      ),
    );
  }

  String? _pickFirst(List<String?> candidates) {
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }
}

/// -------------------------
/// Small circular icon button
/// -------------------------
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
