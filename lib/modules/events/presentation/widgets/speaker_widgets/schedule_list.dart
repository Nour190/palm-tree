import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/session_card.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  final List<Speaker> speakers;
  const ScheduleList({super.key, required this.speakers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: speakers
          .map(
            (sp) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SessionCard(speaker: sp),
            ),
          )
          .toList(),
    );
  }
}
