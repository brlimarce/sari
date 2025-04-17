import 'dart:convert';

import 'package:sari/models/dealer_model.dart';

class Review {
  final DateTime? created_at;
  final int product_rating;
  final int seller_rating;
  final String review;
  final Dealer? reviewed_by;

  Review({
    required this.product_rating,
    required this.seller_rating,
    required this.review,
    this.created_at,
    this.reviewed_by,
  });

  /// Instantiate [Review] from [JSON] format.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      product_rating: double.parse(json['product_rating']).toInt(),
      seller_rating: double.parse(json['seller_rating']).toInt(),
      review: json['review'],
      reviewed_by: json['reviewed_by'] != null
          ? Dealer.fromJson(json['reviewed_by'])
          : null,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convert each entry into [Review] object.
  static List<Review> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Review>((dynamic d) => Review.fromJson(d)).toList();
  }

  /// Convert [Review] into [JSON].
  static Map<String, dynamic> toJson(Review d, String transaction) {
    return {
      'product_rating': d.product_rating,
      'seller_rating': d.seller_rating,
      'review': d.review,
      'transaction': transaction,
    };
  }
}
