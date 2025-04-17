import 'dart:convert';

import 'package:sari/models/dealer_model.dart';

class BidViewModel {
  final String? id;
  final String product;
  final Dealer purchased_by;
  final double bid_amount;

  BidViewModel({
    this.id,
    required this.product,
    required this.purchased_by,
    required this.bid_amount,
  });

  /// Instantiate [BidViewModel] from [JSON] format.
  factory BidViewModel.fromJson(Map<String, dynamic> json) {
    return BidViewModel(
      id: json['id'],
      product: json['product'],
      purchased_by: Dealer.fromJson(json['purchased_by']),
      bid_amount: double.parse(json['bid_amount']),
    );
  }

  /// Convert each entry into [BidViewModel] object.
  static List<BidViewModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<BidViewModel>((dynamic d) => BidViewModel.fromJson(d))
        .toList();
  }
}
