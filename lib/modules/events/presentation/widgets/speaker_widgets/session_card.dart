import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

import '../../../../../core/resourses/navigation_manger.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../view/speakers_info_view.dart';

class SessionCard extends StatelessWidget {
  final Speaker speaker;
  final int index;
  final void Function(int index)? onTap;
  final bool isDesktop;

  const SessionCard({
    super.key,
    required this.speaker,
    required this.index,
    this.onTap,
    this.isDesktop = false,
  });

  String _formatTimeLocal(DateTime utc) =>
      DateFormat.jm().format(utc.toLocal());

  @override
  Widget build(BuildContext context) {
    final isHighlighted = speaker.isLive;
    final bg = isHighlighted ? AppColor.black : AppColor.white;
    final fg = isHighlighted ? AppColor.white : AppColor.black;
    final border = isHighlighted ? AppColor.transparent : AppColor.blueGray100;

    final timeLabel = _formatTimeLocal(speaker.startAt);
    final title = (speaker.topicName?.trim().isNotEmpty == true)
        ? speaker.topicName!
        : speaker.name;
    final summary = (speaker.topicDescription?.trim().isNotEmpty == true)
        ? speaker.topicDescription!
        : (speaker.bio ?? '');

    return GestureDetector(
      onTap: () {
        navigateTo(
          context,
            SpeakersInfoScreen(speaker: speaker,));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: isDesktop
              ? _buildDesktopLayout(timeLabel, title, summary, fg, isHighlighted)
              : _buildMobileLayout(timeLabel, title, summary, fg, isHighlighted),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(String timeLabel, String title, String summary, Color fg, bool isHighlighted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time section
        Container(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isHighlighted ? Icons.podcasts : Icons.schedule,
                    size: 18,
                    color: fg.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  if (isHighlighted)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                timeLabel,
                style: TextStyleHelper.instance.title16BoldInter.copyWith(
                  fontSize: 18,
                  color: fg,
                ),
              ),
            ],
          ),
        ),

         SizedBox(width: 1.sW),

        // Content section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                  fontSize: 20.sSp,
                  color: fg,
                ),
              ),
               SizedBox(height: 8.sH),
              Text(
                summary,
                style: TextStyleHelper.instance.title14BlackRegularInter.copyWith(
                  color: fg.withOpacity(0.85),
                  height: 1.2,
                ),maxLines: 6,overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (speaker.city != null || speaker.country != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: fg.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      [
                        speaker.city,
                        speaker.country,
                      ].where((e) => (e ?? '').isNotEmpty).join(', '),
                      style: TextStyleHelper.instance.body14RegularInter.copyWith(
                        color: fg.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Action section
        if (isHighlighted && speaker.url != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Join Live',
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(String timeLabel, String title, String summary, Color fg, bool isHighlighted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 12),
          child: Icon(
            isHighlighted ? Icons.podcasts : Icons.schedule,
            size: 16,
            color: fg.withOpacity(0.8),
          ),
        ),
        Text(
          timeLabel,
          style: TextStyleHelper.instance.title16BoldInter.copyWith(
            color: fg,
          ),
        ),
         SizedBox(width: 16.sW),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyleHelper.instance.title14BoldInter.copyWith(
                  color: fg,
                ),
              ),
               SizedBox(height: 6.sH),
              Text(
                summary,
                style: TextStyleHelper.instance.body12MediumInter
                    .copyWith(color: fg.withOpacity(0.85)
                ),
              maxLines: 4,overflow: TextOverflow.ellipsis,),
              const SizedBox(height: 8),
              if (speaker.city != null || speaker.country != null)
                Text(
                  [
                    speaker.city,
                    speaker.country,
                  ].where((e) => (e ?? '').isNotEmpty).join(', '),
                  style: TextStyleHelper.instance.title16RegularInter
                      .copyWith(
                    fontSize: 12,
                    color: fg.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
