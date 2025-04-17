import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sari/models/dealer_model.dart';
import 'package:sari/models/product_model.dart';
import 'package:sari/models/views/dealer_view_model.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/utils/constants.dart';

class MockData {
  static const String NULL = 'null';
  static final String IMAGE_URL = dotenv.env['FIREBASE_PLACEHOLDER_IMAGE_URL']!;
  static const String DEALER_IMAGE_URL =
      "https://lh3.googleusercontent.com/a/ACg8ocJfJF-e93C_OK9u79RLkvQM8_CEjrFJsluyK8U7Rfj-gVsL5pTn=s360-c-no";

  // Fake User
  static final Dealer dealer = Dealer(
    fb_id: 'KHw26ErMiRJCkfAWLpMB',
    display_name: 'John Doe',
    email: 'sariapps.user@gmail.com',
    photo_url: DEALER_IMAGE_URL,
    contact_number: '09052217364',
    rating: 0.0,
  );

  // Fake Preview
  static final PreviewViewModel preview = PreviewViewModel(
    id: '1',
    name: 'Deleted Product',
    thumbnail_url: IMAGE_URL.toString(),
    selling_type: SELLING_TYPE.keys.first,
    status: 'Processing',
    default_price: 40,
    end_date: DateTime.now(),
    scan_url: '/',
    is_bookmarked: false,
    category: 'Furniture',
    created_by: dealer,
    timestamp: 0,
  );

  // Fake Product
  static final Product product = Product(
    category: 'Furniture',
    name: 'Deleted Product',
    description: 'This is a description.',
    selling_type: SELLING_TYPE.keys.first,
    end_date: DateTime.now(),
    thumbnail_url: '/',
    scan_url: '/',
    payment_method: [],
    meetup_place: [],
    meetup_schedule: [],
    product_keyword: ["keyword1", "keyword2", "keyword3"],
    mine_price: 10,
    grab_price: 20,
    steal_increment: 10,
    stock_qty: 10,
    default_price: 40,
    created_by: null,
  );

  // Fake Dealer View
  static final DealerViewModel dealerView = DealerViewModel(
    dealer: dealer,
    products: List.filled(4, preview),
  );

  // List of Fake Previews
  static final List<PreviewViewModel> previewList = List.filled(6, preview);

  // Fake Checkbox Items
  static final List<Map<String, dynamic>> checkboxes = List.filled(3, {
    "name": "Option Name",
    "id": "",
    "checked": false,
  });
}
