class WeekModel {
  final List<String> weekdays;
  final List<int> dates;
  final int selectedIndex;

  const WeekModel({
    required this.weekdays,
    required this.dates,
    required this.selectedIndex,
  }) : assert(weekdays.length == 7),
       assert(dates.length == 7),
       assert(selectedIndex >= 0 && selectedIndex < 7);

  factory WeekModel.fromJson(Map<String, dynamic> json) {
    return WeekModel(
      weekdays: List<String>.from(json['weekdays']),
      dates: List<int>.from(json['dates']),
      selectedIndex: json['selectedIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekdays': weekdays,
      'dates': dates,
      'selectedIndex': selectedIndex,
    };
  }
}
