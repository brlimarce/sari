import 'dart:convert';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  /// Instantiate [Category] from [JSON] format.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  /// Convert each entry into [Category] object.
  static List<Category> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Category>((dynamic d) => Category.fromJson(d)).toList();
  }

  /// Convert each [Category] into [Map] object.
  static List<Map<String, dynamic>> toMap(List<Category> data) {
    return data
        .map<Map<String, dynamic>>((dynamic d) => {
              "id": d.id,
              "name": d.name,
              "checked": false,
            })
        .toList();
  }
}
