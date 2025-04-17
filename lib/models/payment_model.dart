import 'dart:convert';

class PaymentMethod {
  final String id;
  final String name;
  final String? account_name;
  final String? account_number;

  PaymentMethod({
    required this.id,
    required this.name,
    this.account_name,
    this.account_number,
  });

  /// Instantiate [PaymentMethod] from [JSON] format.
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      account_name: json['account_name'] ?? '',
      account_number: json['account_number'] ?? '',
    );
  }

  /// Convert each entry into [PaymentMethod] object.
  static List<PaymentMethod> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<PaymentMethod>((dynamic d) => PaymentMethod.fromJson(d))
        .toList();
  }

  /// Convert each [PaymentMethod] into [Map] object.
  static List<Map<String, dynamic>> toMap(List<PaymentMethod> data) {
    return data
        .map<Map<String, dynamic>>((dynamic d) => {
              "id": d.id,
              "name": d.name,
              "checked": false,
              "account_name": "",
              "account_number": "",
            })
        .toList();
  }
}
