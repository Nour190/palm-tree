import 'package:baseqat/modules/events/presentation/widgets/speaker_widgets/session_card.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  final List<Speaker> speakers;
  final void Function(int index)? onTap;

  const ScheduleList({super.key, required this.speakers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: speakers
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SessionCard(
                speaker: entry.value,
                index: entry.key,
                onTap: onTap,
              ),
            ),
          )
          .toList(),
    );
  }
}
