import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:logger/logger.dart';
import 'package:sari/models/review_model.dart';
import 'package:sari/models/transaction_model.dart';
import 'package:sari/models/views/bid_view_model.dart';
import 'package:sari/services/transaction_service.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/error_handler.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/utils.dart';

class TransactionProvider with ChangeNotifier {
  late TransactionService _service;
  late FlutterSecureStorage _storage;
  late Logger _logger;
  late ErrorHandler error;

  TransactionProvider() {
    _service = TransactionService();
    _storage = const FlutterSecureStorage();
    _logger = Logger();
    error = ErrorHandler();
  }

  /// Add a [Transaction] to the server for
  /// products that are of type [RECURRENT SELLING].
  ///
  /// The method will take in the [productId] and the [qty]
  /// of the product that the user wants to purchase.
  Future<int> createPurchase(String productId, int qty) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.createPurchase(productId, qty, token!);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.CREATED) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(TransactionError.PURCHASE_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Add a [Transaction] to the server for
  /// products that are of type [FOR BIDDING].
  ///
  /// The method will take in the [productId] and the [bid]
  /// of the product that the user wants to bid.
  Future<int> createBid(String productId, {double? bid}) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.createBid(productId, token!, bid: bid);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.CREATED) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(TransactionError.BID_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Create a [Review] for the [Transaction].
  ///
  /// The [transactionId] is the transaction that will be reviewed.
  Future<int> createReview(String transactionId, Review review) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.createReview(
          token!, Review.toJson(review, transactionId));

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.CREATED) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.CREATE_FAILED_ERROR("review", isPersonal: true));

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Retrieve the [Review] of the [Transaction].
  ///
  /// The method will return a [List] of [Review] objects.
  Future<List<Review>> getReviews(String productId) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getReviews(token!, productId);
      return Review.fromJsonArray(data.body);
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("product's reviews"));

      notifyListeners();
      return [];
    }
  }

  /// Retrieve all the [Transaction] from the database.
  ///
  /// The method will return a [Stream] of [List] of [Transaction] objects.
  Stream<List<Transaction>> getAllTransactions(
      {Map<String, dynamic>? filters}) async* {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data =
          await _service.getAllTransactions(token!, filters: filters);
      yield Transaction.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("transactions"));

      notifyListeners();
      yield [];
    }
  }

  /// Retrieve the highest [Transaction] from the database.
  Future<List<BidViewModel>> getHighestBids(String productId) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getHighestBids(productId, token!);
      return BidViewModel.fromJsonArray(data.body);
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("highest bids"));

      notifyListeners();
      return [];
    }
  }

  /// Manage and process the meetup of the [Transaction].
  /// This will update some fields, depending on its status.
  ///
  /// The [id] is the transaction that will be updated.
  /// The [product] should be related to the transaction.
  /// The [user] is the current user who is trying to take action.
  Future<int> manageMeetup(String id, String product, String user,
      {Map<String, dynamic>? data}) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response response =
          await _service.manageMeetup(token!, id, product, user, data ?? {});

      // Throw the exception if the request has an error.
      if (response.statusCode != StatusCode.NO_CONTENT) {
        throw Exception(response.body);
      }

      return response.statusCode;
    } on Exception catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(TransactionError.GENERIC_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }
}
