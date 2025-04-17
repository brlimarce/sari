import 'dart:convert';

import 'package:sari/models/dealer_model.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/utils/mock_data.dart';

class Transaction {
  final String? id;
  final String status;
  final Dealer purchased_by;
  final PreviewViewModel product;

  // Meetup Details
  final Place? place;
  final String? payment_method;
  final String? schedule;

  final double? bid_amount; // For Bidding
  final int? qty; // Recurrent Selling

  final String? payment_reference;

  Transaction({
    this.id,
    required this.status,
    required this.purchased_by,
    required this.product,
    this.place,
    this.payment_method,
    this.schedule,
    this.bid_amount,
    this.qty,
    this.payment_reference,
  });

  /// Instantiate [Transaction] from [JSON] format.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      status: json['status'],
      purchased_by: Dealer.fromJson(json['purchased_by']),
      product: json['product'] != null
          ? PreviewViewModel.fromJson(json['product'])
          : MockData.preview,
      place: json['place'] != null ? Place.fromJson(json['place']) : null,
      payment_method: json['payment_method'],
      schedule: json['schedule'] ?? "",
      bid_amount:
          json['bid_amount'] != null ? double.parse(json['bid_amount']) : 0.0,
      qty: json['qty'],
      payment_reference: json['payment_reference'],
    );
  }

  /// Convert each entry into the [Transaction] object.
  ///
  /// Returns a [List<Transaction>] object containing
  /// the [Transaction] objects.
  static List<Transaction> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<Transaction>((dynamic d) => Transaction.fromJson(d))
        .toList();
  }

  /// Convert the [Transaction] object into [JSON].
  Map<String, dynamic> toJson(Transaction d) {
    return {
      "id": d.id,
      "status": d.status,
      "purchased_by": d.purchased_by,
      "product": d.product,
      "place": d.place,
      "payment_method": d.payment_method,
      "schedule": d.schedule,
      "bid_amount": d.bid_amount,
      "qty": d.qty,
      "payment_reference": d.payment_reference,
    };
  }
}
