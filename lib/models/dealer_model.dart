import 'dart:convert';

class Dealer {
  final String? id;
  final String fb_id; // Firebase ID
  final String display_name;
  final String email;
  final String? contact_number;
  final String photo_url;
  final String? chat_url;
  final double? rating;

  Dealer({
    this.id,
    required this.fb_id,
    required this.display_name,
    required this.email,
    required this.photo_url,
    this.contact_number,
    this.chat_url,
    this.rating,
  });

  /// Instantiate [Dealer] from [JSON] format.
  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id'],
      fb_id: json['fb_id'],
      display_name: json['display_name'],
      email: json['email'],
      contact_number: json['contact_number'],
      photo_url: json['photo_url'],
      chat_url: json['chat_url'],
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  /// Convert each entry into the [Dealer] object.
  ///
  /// Returns a [List<Dealer>] object containing
  /// the [Dealer] objects.
  static List<Dealer> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Dealer>((dynamic d) => Dealer.fromJson(d)).toList();
  }

  /// Convert [Dealer] into [JSON].
  static Map<String, dynamic> toJson(Dealer d) {
    return {
      'id': d.id,
      'fb_id': d.fb_id,
      'display_name': d.display_name,
      'email': d.email,
      'contact_number': d.contact_number,
      'photo_url': d.photo_url,
      'chat_url': d.chat_url,
      'rating': d.rating,
    };
  }
}
