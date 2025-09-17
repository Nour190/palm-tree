import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

navigateTo(context, screen) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

navigateAndReplace(context, screen) => Navigator.of(
  context,
).pushReplacement(MaterialPageRoute(builder: (_) => screen));

navigateAndFinished(context, screen) =>
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );

String getTimeWithAMPM(TimeOfDay time) {
  final now = DateTime.now();
  final DateTime dateTime = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  final format = DateFormat.jm();
  return format.format(dateTime);
}
