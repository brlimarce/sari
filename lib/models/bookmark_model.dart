import 'dart:convert';

import 'package:sari/models/dealer_model.dart';
import 'package:sari/models/views/preview_view_model.dart';

class Bookmark {
  PreviewViewModel product;
  Dealer bookmarked_by;

  Bookmark({required this.product, required this.bookmarked_by});

  /// Instantiate [BBookmark] from [JSON] format.
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      product: PreviewViewModel.fromJson(json['bookmarked_product']),
      bookmarked_by: Dealer.fromJson(json['dealer']),
    );
  }

  /// Convert each entry into [Category] object.
  static List<Bookmark> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Bookmark>((dynamic d) => Bookmark.fromJson(d)).toList();
  }
}
