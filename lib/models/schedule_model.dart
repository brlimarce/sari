import 'dart:convert';

class Schedule {
  final String id;
  final DateTime start_date;
  final DateTime end_date;

  Schedule({
    required this.id,
    required this.start_date,
    required this.end_date,
  });

  /// Instantiate [Schedule] from [JSON] format.
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      start_date: DateTime.parse(json['start_date']),
      end_date: DateTime.parse(json['end_date']),
    );
  }

  /// Convert each entry into [Schedule] object.
  static List<Schedule> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Schedule>((dynamic d) => Schedule.fromJson(d)).toList();
  }

  /// Convert [Schedule] into [JSON].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': start_date.toString(),
      'end_date': end_date.toString(),
    };
  }
}
