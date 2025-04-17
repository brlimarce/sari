import 'dart:convert';

import 'package:sari/models/dealer_model.dart';

class PreviewViewModel {
  final String? id;
  final String name;
  final String selling_type;
  final String status;
  final double default_price;
  final DateTime end_date;
  final String thumbnail_url;
  final Dealer created_by;
  final int timestamp;
  final String scan_url;

  final String? category;
  final bool? is_bookmarked;

  final Dealer? highest_bidder;
  final int? order_quantity;
  final double? rating;

  PreviewViewModel({
    this.id,
    required this.name,
    required this.selling_type,
    required this.status,
    required this.default_price,
    required this.end_date,
    required this.thumbnail_url,
    required this.created_by,
    required this.timestamp,
    required this.scan_url,
    this.category,
    this.is_bookmarked,
    this.highest_bidder,
    this.order_quantity,
    this.rating,
  });

  /// Instantiate [PreviewViewModel] from [JSON] format.
  factory PreviewViewModel.fromJson(Map<String, dynamic> json) {
    return PreviewViewModel(
      id: json['id'],
      name: json['name'],
      selling_type: json['selling_type'],
      status: json['status'],
      default_price: double.parse(json['default_price']),
      category: json['category'],
      end_date: DateTime.parse(json['end_date']),
      is_bookmarked: json['is_bookmarked'],
      thumbnail_url: json['thumbnail_url'],
      created_by: Dealer.fromJson(json['created_by']),
      timestamp: json['timestamp'],
      scan_url: json['scan_url'],
      highest_bidder: json['highest_bidder'] != null
          ? Dealer.fromJson(json['highest_bidder'])
          : null,
      order_quantity: json['order_quantity'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  /// Convert each entry into [PreviewViewModel] object.
  static List<PreviewViewModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<PreviewViewModel>((dynamic d) => PreviewViewModel.fromJson(d))
        .toList();
  }
}
