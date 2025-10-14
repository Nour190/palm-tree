import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/workshop_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WorkshopCardWidget extends StatelessWidget {
  const WorkshopCardWidget({
    super.key,
    required this.workshop,
    required this.languageCode,
    this.onTap,
    this.showTimeBadge = true,
  });

  final Workshop workshop;
  final String languageCode;
  final VoidCallback? onTap;
  final bool showTimeBadge;

  String _getLocalizedName() {
    return languageCode == 'ar'
        ? (workshop.nameAr?.isNotEmpty == true ? workshop.nameAr! : workshop.name)
        : workshop.name;
  }

  String _getLocalizedDescription() {
    return languageCode == 'ar'
        ? (workshop.descriptionAr?.isNotEmpty == true
        ? workshop.descriptionAr!
        : workshop.description ?? '')
        : (workshop.description ?? '');
  }

  String _getInstructorName() {
    return languageCode == 'ar'
        ? (workshop.artistNameAr?.isNotEmpty == true
        ? workshop.artistNameAr!
        : workshop.artistName ?? 'programs.workshop.no_instructor'.tr())
        : (workshop.artistName ?? 'programs.workshop.no_instructor'.tr());
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return DateFormat.jm(locale.toLanguageTag()).format(dateTime.toLocal());
  }

  String _getTimeRange(BuildContext context) {
    final start = _formatTime(workshop.startAt, context);
    final end = _formatTime(workshop.endAt, context);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = languageCode == 'ar';
    final name = _getLocalizedName();
    final description = _getLocalizedDescription();
    final instructor = _getInstructorName();
    final timeRange = _getTimeRange(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 156,
          decoration: BoxDecoration(
            color: AppColor.white,
            border: Border.all(color: AppColor.black, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side: Time badge (rotated)
              if (showTimeBadge)
                SizedBox(
                  width: 40,
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        color: AppColor.black,
                      ),
                      // Rotated text
                      Center(
                        child: Transform.rotate(
                          angle: -1.5708, // -90 degrees in radians
                          child: Text(
                            timeRange,
                            style: const TextStyle(
                              color: AppColor.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                              letterSpacing: -0.022,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Middle: Workshop image
              Container(
                width: 92,
                decoration: BoxDecoration(
                  color: AppColor.gray100,
                  border: Border.all(color: AppColor.black, width: 1),
                ),
                child: workshop.coverImage != null
                    ? OfflineCachedImage(
                  imageUrl: workshop.coverImage!,
                  fit: BoxFit.cover,
                  errorWidget: const _PlaceholderImage(
                    icon: Icons.image_outlined,
                  ),
                )
                    : const _PlaceholderImage(icon: Icons.image_outlined),
              ),

              // Right side: Workshop details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section: Title and description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workshop title
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                              letterSpacing: -0.022,
                              height: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Workshop description
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: const TextStyle(
                                color: AppColor.black,
                                fontSize: 8,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Inter',
                                letterSpacing: -0.022,
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),

                      // Bottom section: Instructor info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Instructor info
                          Expanded(
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColor.black,
                                      width: 0.5,
                                    ),
                                    color: AppColor.gray200,
                                  ),
                                  child: workshop.coverImage != null
                                      ? ClipOval(
                                    child: OfflineCachedImage(
                                      imageUrl: workshop.coverImage!,
                                      fit: BoxFit.cover,
                                      errorWidget: const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: AppColor.gray400,
                                      ),
                                    ),
                                  )
                                      : const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColor.gray400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Name and role
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        instructor,
                                        style: const TextStyle(
                                          color: AppColor.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter',
                                          letterSpacing: -0.022,
                                          height: 1.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Artist',
                                        style: TextStyle(
                                          color: AppColor.black,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: 'Inter',
                                          letterSpacing: -0.022,
                                          height: 1.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arrow button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColor.black,
                              shape: BoxShape.circle,
                            ),
                            child: Transform.rotate(
                              angle: 0.5236, // 30 degrees in radians
                              child: const Icon(
                                Icons.arrow_upward,
                                color: AppColor.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.gray100,
      child: Center(
        child: Icon(
          icon,
          size: 36,
          color: AppColor.gray400,
        ),
      ),
    );
  }
}

class WorkshopList extends StatelessWidget {
  const WorkshopList({
    super.key,
    required this.workshops,
    required this.languageCode,
    this.onWorkshopTap,
    this.showTimeBadges = true,
    this.spacing,
  });

  final List<Workshop> workshops;
  final String languageCode;
  final ValueChanged<Workshop>? onWorkshopTap;
  final bool showTimeBadges;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final itemSpacing = spacing ?? 8.0;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workshops.length,
      separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final workshop = workshops[index];
        return WorkshopCardWidget(
          workshop: workshop,
          languageCode: languageCode,
          showTimeBadge: showTimeBadges,
          onTap: onWorkshopTap != null ? () => onWorkshopTap!(workshop) : null,
        );
      },
    );
  }
}
