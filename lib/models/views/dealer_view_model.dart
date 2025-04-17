import 'package:sari/models/dealer_model.dart';
import 'package:sari/models/views/preview_view_model.dart';

class DealerViewModel {
  final Dealer dealer;
  final List<PreviewViewModel>? products;

  DealerViewModel({required this.dealer, this.products});

  /// Convert a JSON object into a [DealerViewModel] instance.
  static DealerViewModel fromJson(Map<String, dynamic> json) {
    return DealerViewModel(
      dealer: Dealer.fromJson({
        'id': json['id'],
        'fb_id': json['fb_id'],
        'display_name': json['display_name'],
        'email': json['email'],
        'contact_number': json['contact_number'],
        'photo_url': json['photo_url'],
        'chat_url': json['chat_url'],
        'rating': json['rating'],
      }),
      products: (json['products'] as List<dynamic>)
          .map((p) => PreviewViewModel.fromJson(p))
          .toList(),
    );
  }
}
