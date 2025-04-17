import 'dart:convert';

class ReviewViewModel {
  final double? average_rating;
  final double? average_product_rating;
  final double? average_seller_rating;
  final String review;

  ReviewViewModel({
    this.average_rating,
    this.average_product_rating,
    this.average_seller_rating,
    required this.review,
  });

  /// Instantiate [ReviewViewModel] from [JSON] format.
  factory ReviewViewModel.fromJson(Map<String, dynamic> json) {
    return ReviewViewModel(
      average_rating: double.tryParse(json['average_rating']),
      average_product_rating: double.tryParse(json['average_product_rating']),
      average_seller_rating: double.tryParse(json['average_seller_rating']),
      review: json['review'],
    );
  }

  /// Convert each entry into [Review] object.
  static List<ReviewViewModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<ReviewViewModel>((dynamic d) => ReviewViewModel.fromJson(d))
        .toList();
  }
}
