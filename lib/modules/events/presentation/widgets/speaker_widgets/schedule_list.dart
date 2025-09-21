import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/session_card.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  final List<Speaker> speakers;
  final void Function(int index)? onTap;
  final bool isDesktop;
  final String userId;

  const ScheduleList({
    super.key,
    required this.speakers,
    required this.onTap,
    this.isDesktop = false,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (speakers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: isDesktop ? 64 : 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions scheduled for this day',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: speakers
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
              child: SessionCard(
                speaker: entry.value,
                index: entry.key,
                onTap: onTap,
                userId: userId,
                isDesktop: isDesktop,
              ),
            ),
          )
          .toList(),
    );
  }
}
