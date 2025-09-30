import 'package:flutter/material.dart';
import 'week_model.dart';

class MonthData {
  DateTime currentMonth;
  final WeekModel week;
  final String monthLabel;
  final VoidCallback prevMonth;
  final VoidCallback nextMonth;

  MonthData({
    required this.currentMonth,
    required this.week,
    required this.monthLabel,
    required this.prevMonth,
    required this.nextMonth,
  });
}

class MonthWidget extends StatefulWidget {
  final DateTime? initialMonth;
  final WeekModel? week;
  final Widget Function(BuildContext context, MonthData monthData) builder;

  const MonthWidget({
    Key? key,
    this.initialMonth,
    this.week,
    required this.builder,
  }) : super(key: key);

  @override
  State<MonthWidget> createState() => _MonthWidgetState();
}

class _MonthWidgetState extends State<MonthWidget> {
  late DateTime _currentMonth;

  static const _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  String get _monthLabel =>
      "${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}";

  static const _weekJson = {
    "weekdays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
    "dates": [1, 2, 3, 4, 5, 6, 7],
    "selectedIndex": 0,
  };

  late WeekModel _week;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth ?? DateTime(2025, 10);
    _week = widget.week ?? WeekModel.fromJson(_weekJson);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = MonthData(
      currentMonth: _currentMonth,
      week: _week,
      monthLabel: _monthLabel,
      prevMonth: _prevMonth,
      nextMonth: _nextMonth,
    );

    return widget.builder(context, data);
  }
}
