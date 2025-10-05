import 'package:flutter/material.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'session_card.dart';

class ScheduleList extends StatelessWidget {
  final List<Speaker> speakers;
  final String userId;
  final bool isDesktop;

  const ScheduleList({
    super.key,
    required this.speakers,
    required this.userId,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (speakers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(color: AppColor.blueGray100),
        ),
        child: const Text('No sessions for this day.'),
      );
    }

    return Column(
      children: List.generate(speakers.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == speakers.length - 1 ? 0 : 12.sH),
          child: SessionCard(
            speaker: speakers[i],
            index: i,
            userId: userId,
            isDesktop: isDesktop,
          ),
        );
      }),
    );
  }
}
