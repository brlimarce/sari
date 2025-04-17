import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sari/utils/constants.dart';

class ProductFormProvider with ChangeNotifier {
  late Logger _logger;

  /// [Properties]
  late String category;
  late String name;
  late String description;
  late String selling_type;
  late double? default_price;

  late String end_date;
  late String end_time;

  late String thumbnail_url;
  late String scan_url;

  late List<Map<String, dynamic>> payment_method;
  late List<Map<String, dynamic>> meetup_place;
  late List<dynamic> product_keyword;

  late List<dynamic> schedule_date;
  late List<dynamic> schedule_start_time;
  late List<dynamic> schedule_end_time;

  /// [For Bidding]
  late double? mine_price;
  late double? grab_price;
  late int? steal_increment;

  /// [Recurrent Selling]
  late int? stock_qty;

  /// [Extra/For Tracking]
  late int payment_counter;
  late int place_counter;

  ProductFormProvider() {
    _logger = Logger();
    reset();
  }

  /// Save the product information after
  /// proceeding to the next step.
  void setProductDetails(Map<String, dynamic> state) {
    // Set the product information.
    category = state['category'];
    name = state['name'];
    description = state['description'];
    selling_type = state['selling_type'];
    thumbnail_url = state['thumbnail_url'];
    product_keyword = state['product_keyword'];

    // Display the updated state.
    _logger.d(selling_type);
  }

  /// Save the prices and selling end date.
  void setSellingDetails(Map<String, dynamic> state) {
    // Set the selling details based on the selling type.
    if (selling_type == SELLING_TYPE.keys.first) {
      mine_price = state['mine_price'];
      grab_price = state['grab_price'];
      steal_increment = state['steal_increment'];
    } else {
      default_price = state['default_price'];
      stock_qty = state['stock_qty'];
    }

    // Set the selling end date.
    end_date = state['end_date'];
    end_time = state['end_time'];

    // Display the updated state.
    _logger.d(default_price);
  }

  /// Save the payment methods, meetup places,
  /// and meetup schedules.
  void setMeetupDetails(Map<String, dynamic> state) {
    // Set the meetup details.
    payment_method = state['payment_method'];
    payment_counter = state['payment_counter'];
    meetup_place = state['meetup_place'];
    place_counter = state['place_counter'];
    schedule_date = state['schedule_date'];
    schedule_start_time = state['schedule_start_time'];
    schedule_end_time = state['schedule_end_time'];

    // Display the updated state.
    _logger.d(schedule_date);
  }

  /// Reset the product form state.
  void reset() {
    category = '';
    name = '';
    description = '';
    selling_type = SELLING_TYPE.keys.first;

    default_price = 0;
    end_date = '';
    end_time = '';

    thumbnail_url = '';
    scan_url = '';

    payment_method = [];
    meetup_place = [];
    product_keyword = [];
    schedule_date = [];
    schedule_start_time = [];
    schedule_end_time = [];

    payment_counter = 0;
    place_counter = 0;

    // For Bidding
    mine_price = 0;
    grab_price = 0;
    steal_increment = 10;
    stock_qty = 0;
  }

  /// Reset the fields of the meetup schedule.
  void resetSchedule() {
    schedule_date = [];
    schedule_start_time = [];
    schedule_end_time = [];
  }
}
