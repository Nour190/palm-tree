import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/resourses/style_manager.dart';

class EventCardWidget extends StatelessWidget {
  final Event event;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final String languageCode;

  const EventCardWidget({
    required this.event,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.languageCode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover Image
        if (event.coverImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
            child: OfflineCachedImage(
              imageUrl: event.coverImage!,
              height: 200.sH,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: ProgramsLayout.spacingMedium(context)),

        // Event Info Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circle Avatar
            if (event.circleAvatar != null)
              ClipOval(
                child: OfflineCachedImage(
                  imageUrl: event.circleAvatar!,
                  height: 35.sW,
                  width: 35.sW,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 35.sW,
                width: 35.sW,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.gray200,
                ),
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColor.gray400,
                ),
              ),

            SizedBox(width:8.sW),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.localizedName(languageCode: languageCode),
                    style: TextStyleHelper.instance.body16MediumInter,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.eventDate != null)
                    Text(
                      DateFormat('MMM d – d, yyyy').format(event.eventDate!),
                      style: ProgramsTypography.bodySecondary(context).copyWith(
                        fontSize: ProgramsLayout.size(context, 12),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width:8.sW),
            GestureDetector(
              onTap: onExpandToggle,
              child: Container(
                height: 35.sW,
                width: 35.sW,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.black,
                ),
                child: Transform.rotate(
                  angle: isExpanded ?3.1416:0,
                  child: Icon(
                    Icons.arrow_outward,
                    color: AppColor.white,
                    size: 22.sW,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
