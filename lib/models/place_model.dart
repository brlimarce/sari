import 'dart:convert';

class Place {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;

  Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Instantiate [ProductPlace] from [JSON] format.
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'] is String
          ? double.tryParse(json['latitude']) ?? 0.0
          : json['latitude'] as double,
      longitude: json['longitude'] is String
          ? double.tryParse(json['longitude']) ?? 0.0
          : json['longitude'] as double,
    );
  }

  /// Convert each entry into [Place] object.
  static List<Place> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Place>((dynamic d) => Place.fromJson(d)).toList();
  }

  /// Convert each [Place] into [Map] object.
  static List<Map<String, dynamic>> toMap(List<Place> data) {
    return data
        .map<Map<String, dynamic>>((dynamic d) => {
              "id": d.id,
              "name": d.name,
              "checked": false,
            })
        .toList();
  }
}
