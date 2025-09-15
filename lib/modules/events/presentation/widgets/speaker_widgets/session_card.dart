import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class SessionCard extends StatelessWidget {
  final Speaker speaker;
  const SessionCard({super.key, required this.speaker});

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

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10.h,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h, right: 12.h),
              child: Icon(
                isHighlighted ? Icons.podcasts : Icons.schedule,
                size: 16.h,
                color: fg.withOpacity(0.8),
              ),
            ),
            Text(
              timeLabel,
              style: TextStyleHelper.instance.headline24BoldInter.copyWith(
                color: fg,
              ),
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleHelper.instance.title16BoldInter.copyWith(
                      color: fg,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    summary,
                    style: TextStyleHelper.instance.title16RegularInter
                        .copyWith(color: fg.withOpacity(0.85)),
                  ),
                  SizedBox(height: 8.h),
                  if (speaker.city != null || speaker.country != null)
                    Text(
                      [
                        speaker.city,
                        speaker.country,
                      ].where((e) => (e ?? '').isNotEmpty).join(', '),
                      style: TextStyleHelper.instance.title16RegularInter
                          .copyWith(
                            fontSize: 12.fSize,
                            color: fg.withOpacity(0.7),
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
}
