import 'dart:convert';

import 'package:sari/utils/constants.dart';

class Product {
  final String? id;
  final String? status;
  final String category;
  final String name;
  final String description;
  final String selling_type;
  final double? default_price;
  final DateTime end_date;
  final bool? is_bookmarked;

  final String thumbnail_url;
  final String scan_url;
  final Map<String, dynamic>? created_by;

  final List<dynamic> payment_method;
  final List<dynamic> meetup_place;
  final List<dynamic> product_keyword;
  final double? rating;

  /// Must be of format [{"start_date", "end_date"}].
  final List<dynamic> meetup_schedule;

  /// [For Bidding]
  final double? mine_price;
  final double? grab_price;
  final int? steal_increment;

  /// [Recurrent Selling]
  final int? stock_qty;

  Product({
    this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.selling_type,
    required this.end_date,
    required this.thumbnail_url,
    required this.scan_url,
    required this.payment_method,
    required this.meetup_place,
    required this.meetup_schedule,
    required this.product_keyword,
    this.created_by,
    this.status,
    this.default_price,
    this.mine_price,
    this.grab_price,
    this.steal_increment,
    this.stock_qty,
    this.is_bookmarked = false,
    this.rating,
  });

  /// Instantiate [Product] from [JSON] format.
  factory Product.fromJson(Map<String, dynamic> json) {
    /// Convert the fields, depending on [selling_type].
    String selling_type = json['selling_type'];

    if (selling_type == SELLING_TYPE.keys.first) {
      // For Bidding
      return Product(
        id: json['id'],
        status: json['status'],
        category: json['category'],
        name: json['name'],
        description: json['description'],
        selling_type: selling_type,
        end_date: DateTime.parse(json['end_date']),
        is_bookmarked: json['is_bookmarked'],
        thumbnail_url: json['thumbnail_url'],
        scan_url: json['scan_url'],
        created_by: json['created_by'],
        payment_method: json['payment_method'],
        meetup_place: json['meetup_place'],
        meetup_schedule: json['meetup_schedule'],
        product_keyword: json['product_keyword'],
        mine_price: double.tryParse(json['mine_price']),
        grab_price: double.tryParse(json['grab_price']),
        steal_increment: json['steal_increment'],
        default_price: double.tryParse(json['default_price']),
        rating: (json['rating'] as num?)?.toDouble(),
      );
    } else {
      // Recurrent Selling
      return Product(
        id: json['id'],
        status: json['status'],
        category: json['category'],
        name: json['name'],
        description: json['description'],
        selling_type: selling_type,
        end_date: DateTime.parse(json['end_date']),
        is_bookmarked: json['is_bookmarked'] ?? false,
        thumbnail_url: json['thumbnail_url'],
        scan_url: json['scan_url'],
        created_by: json['created_by'],
        payment_method: json['payment_method'],
        meetup_place: json['meetup_place'],
        meetup_schedule: json['meetup_schedule'],
        product_keyword: json['product_keyword'],
        stock_qty: json['stock_qty'],
        default_price: double.tryParse(json['default_price']),
        rating: (json['rating'] as num?)?.toDouble(),
      );
    }
  }

  /// Convert each entry into [Product] object.
  static List<Product> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Product>((dynamic d) => Product.fromJson(d)).toList();
  }

  /// Convert [Product] into [JSON].
  Map<String, dynamic> toJson(Product d) {
    return {
      'id': d.id,
      'category': d.category,
      'name': d.name,
      'description': d.description,
      'selling_type': d.selling_type,
      'end_date': d.end_date.toString(),
      'thumbnail_url': d.thumbnail_url,
      'scan_url': d.scan_url,
      'payment_method': d.payment_method,
      'meetup_place': d.meetup_place,
      'meetup_schedule': d.meetup_schedule,
      'product_keyword': d.product_keyword,
      'mine_price': d.mine_price,
      'grab_price': d.grab_price,
      'steal_increment': d.steal_increment,
      'stock_qty': d.stock_qty,
      'default_price': d.default_price
    };
  }
}
