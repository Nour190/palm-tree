import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/resourses/navigation_manger.dart';
import '../../view/more_details_views_tabs/speakers_info_view.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

class SessionCard extends StatelessWidget {
  final Speaker speaker;
  final String userId;
  final int index;
  final bool isDesktop;

  const SessionCard({
    super.key,
    required this.speaker,
    required this.index,
    required this.userId,
    this.isDesktop = false,
  });

  String _formatTimeLocal(DateTime utc) => DateFormat.jm().format(utc.toLocal());

  @override
  Widget build(BuildContext context) {
    // Black variant for first item (as in photo) or when isLive=true
    final isHighlighted = speaker.isLive == true || index == 0;
    final bg = isHighlighted ? AppColor.black : AppColor.white;
    final fg = isHighlighted ? AppColor.white : AppColor.black;
    final border = isHighlighted ? AppColor.transparent : AppColor.blueGray100;

    final timeLabel = _formatTimeLocal(speaker.startAt).toUpperCase();
    final title = (speaker.topicName?.trim().isNotEmpty == true) ? speaker.topicName! : speaker.name;
    final summary = (speaker.topicDescription?.trim().isNotEmpty == true)
        ? speaker.topicDescription!
        : (speaker.bio ?? '');

    return GestureDetector(
      onTap: () => navigateTo(context, SpeakersInfoScreen(speaker: speaker, userId: userId)),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big time (left)
                  Padding(
                    padding: EdgeInsets.only(top: 2.sH),
                    child: Text(
                      timeLabel,
                      style: (isDesktop
                              ? TextStyleHelper.instance.headline20BoldInter
                              : TextStyleHelper.instance.title16BoldInter)
                          .copyWith(fontSize: isDesktop ? 24.sSp : 20.sSp, letterSpacing: .3, color: fg),
                    ),
                  ),
                  SizedBox(width: 16.sW),

                  // Title + description (right)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: (isDesktop
                                  ? TextStyleHelper.instance.headline20BoldInter
                                  : TextStyleHelper.instance.title14BoldInter)
                              .copyWith(color: fg),
                        ),
                        SizedBox(height: 6.sH),
                        Text(
                          summary,
                          style: (isDesktop
                                  ? TextStyleHelper.instance.title14BlackRegularInter
                                  : TextStyleHelper.instance.body12MediumInter)
                              .copyWith(color: fg.withOpacity(0.88), height: 1.25),
                          maxLines: isDesktop ? 6 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // NE arrow
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.white.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isHighlighted ? Colors.white.withOpacity(0.28) : AppColor.blueGray100,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(
                  Icons.north_east_rounded,
                  size: 16,
                  color: isHighlighted ? Colors.white : AppColor.gray700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
