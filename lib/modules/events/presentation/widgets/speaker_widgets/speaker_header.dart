import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

class SpeakersHeader extends StatelessWidget {
  final String title;
  const SpeakersHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyleHelper.instance.headline32BoldInter);
  }
}
