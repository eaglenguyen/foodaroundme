class OpeningHours {
  final bool isOpenNow;
  final List<WeekdayHours> weekdays;

  OpeningHours({
    required this.isOpenNow,
    required this.weekdays,
});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      isOpenNow: json['is_open_now'] ?? false,
      weekdays: (json['weekdays'] as List<dynamic>? ?? [])
          .map((e) => WeekdayHours.fromJson(e))
          .toList(),
    );
  }
}

class WeekdayHours {
  final int day; // 1= Mon, 7 = Sun
  final List<HourRange> hours;

  WeekdayHours({
    required this.day,
    required this.hours,
});

  factory WeekdayHours.fromJson(Map<String, dynamic> json) {
    return WeekdayHours(
      day: json['day'],
      hours: (json['hours'] as List<dynamic>? ?? [])
          .map((e) => HourRange.fromJson(e))
          .toList(),
    );
  }
}

class HourRange{
  final String from;
  final String to;

  HourRange({
    required this.from,
    required this.to,
});

  factory HourRange.fromJson(Map<String, dynamic> json) {
    return HourRange(
      from: json['from'],
      to: json['to'],
    );
  }
}