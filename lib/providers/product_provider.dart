import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:logger/logger.dart';
import 'package:sari/models/bookmark_model.dart';
import 'package:sari/models/category_model.dart';
import 'package:sari/models/payment_model.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/models/product_model.dart';
import 'package:sari/models/schedule_model.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/services/product_service.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/error_handler.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/utils.dart';

class ProductProvider with ChangeNotifier {
  late ProductService _service;
  late FlutterSecureStorage _storage;
  late Logger _logger;
  late ErrorHandler error;

  ProductProvider() {
    _service = ProductService();
    _storage = const FlutterSecureStorage();
    _logger = Logger();
    error = ErrorHandler();
  }

  /// Add a [Product] to the server.
  ///
  /// The method will take in a [Product] object
  /// from the form.
  Future<Map<String, dynamic>> createProduct(Product product) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.createProduct(product, token!);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.CREATED) {
        throw Exception(data.body);
      }

      return {
        "status": data.statusCode,
        "id": jsonDecode(data.body),
      };
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.CREATE_FAILED_ERROR("product"));

      notifyListeners();
      return {
        "status": StatusCode.INTERNAL_SERVER_ERROR,
        "id": null,
      };
    }
  }

  /// Add a [Product] to the user's [Bookmark] list.
  ///
  /// It will take a [productId] and a [token] as the dealer's ID.
  Future<int> createBookmark(String productId) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.createBookmark(productId, token!);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.CREATED) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.BOOKMARK_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Reconstruct a 3D model of the [Product] from the server.
  Future<int> reconstructProduct(String productId, List<File> files) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data =
          await _service.reconstructProduct(productId, files, token!);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.ACCEPTED) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.RECONSTRUCT_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Publish the [Product] to be viewed by the buyers.
  ///
  /// The method will take in a [String] ID of the product.
  Future<int> publishProduct(String id) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.publishProduct(id, token!);

      // Throw the exception if the request has an error.
      if (data.statusCode != StatusCode.OK) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.PUBLISH_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Retrieve all [Product] from the server,
  /// depending on the selected filters.
  ///
  /// The method will return a [List] of [Product] objects.
  /// If there is an error, the method will return an empty list.
  Stream<List<PreviewViewModel>> getAllProducts(
      {Map<String, dynamic>? filters}) async* {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getAllProducts(token!, filters: filters);
      yield PreviewViewModel.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("products"));

      notifyListeners();
      yield [];
    }
  }

  /// Retrieve a single [Product] from the server.
  ///
  /// The method will return a [Product] object.
  /// If there is an error, the method will return null.
  Future<Product?> getProduct(String id) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getProduct(id, token!);
      return Product.fromJson(jsonDecode(data.body));
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("product"));
      notifyListeners();
    }

    return null;
  }

  /// Retrieve all [Category] from the server.
  ///
  /// The method will return a [List] of [Category] objects.
  Future<List<Category>> getAllCategories() async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getAllCategories(token!);
      return Category.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("categories"));

      notifyListeners();
      return [];
    }
  }

  /// Retrieve all [PaymentMethod] from the server.
  ///
  /// The method will return a [List] of [PaymentMethod] objects.
  Future<List<PaymentMethod>> getAllPaymentMethods(
      {Map<String, dynamic>? filters}) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data =
          await _service.getAllPaymentMethods(token!, filters: filters);
      return PaymentMethod.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("payment methods"));

      notifyListeners();
      return [];
    }
  }

  /// Retrieve all [Place] from the server.
  ///
  /// The method will return a [List] of [Place] objects.
  Future<List<Place>> getAllPlaces({Map<String, dynamic>? filters}) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getAllPlaces(token!, filters: filters);
      return Place.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("places"));

      notifyListeners();
      return [];
    }
  }

  /// Retrieve all [Schedule] from the server.
  ///
  /// The method will return a [List] of [Schedule] objects.
  Future<List<Schedule>> getAllSchedules(
      String product, DateTime startDate) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data =
          await _service.getAllSchedules(token!, product, startDate);
      return Schedule.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("seller's meetup schedule"));

      notifyListeners();
      return [];
    }
  }

  /// Retrieve [Bookmark] from the server.
  Stream<List<Bookmark>> getBookmarks(
      {String? product, String? dealer}) async* {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getBookmarks(token!, filters: {
        "product": product,
        "dealer": dealer,
      });

      yield Bookmark.fromJsonArray(data.body);
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("bookmarks", isPersonal: true));

      notifyListeners();
      yield [];
    }
  }

  /// Reopen the selling of the [Product].
  ///
  /// The method will take in a [String] ID of the product and a [Map] of
  /// the body, which contains the new selling and meetup information.
  Future<int> reopenSelling(String id, Map<String, dynamic> body) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.reopenSelling(id, token!, body);

      if (data.statusCode != StatusCode.NO_CONTENT) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.REOPEN_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Cancel the selling of the [Product] from the server.
  ///
  /// The method will take in a [String] ID of the product.
  Future<int> cancelSelling(String id) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.cancelSelling(id, token!);

      if (data.statusCode != StatusCode.NO_CONTENT) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.CANCEL_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Delete the [Product] from the server.
  ///
  /// The method will take in a [String] ID of the product.
  Future<int> deleteProduct(String id, List<String> mediaUrl) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.deleteProduct(id, token!);

      if (data.statusCode != StatusCode.NO_CONTENT) {
        throw Exception(data.body);
      }

      // Delete the media from Firebase Storage.
      for (String url in mediaUrl) {
        await deleteMediaFromFirebase(url);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.DELETE_FAILED_ERROR("product", isPersonal: true));

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Delete the [Bookmark] from the server.
  ///
  /// The method will take in a [productId] as the ID of the product.
  Future<int> deleteBookmark(String productId) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.deleteBookmark(productId, token!);

      if (data.statusCode != StatusCode.NO_CONTENT) {
        throw Exception(data.body);
      }

      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ProductError.UNBOOKMARK_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Upload a [File] to Firebase Storage.
  ///
  /// The method will take in an image [File]. Then, it
  /// will return a [String] of the URL of the uploaded image.
  Future<String> uploadMediaToFirebase(File image) async {
    String url = "";
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      // Upload the file to Firebase Storage.
      Reference ref = FirebaseStorage.instance.ref().child(image.path);
      UploadTask uploadTask = ref.putFile(image);

      // Get the URL of the uploaded file.
      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(BaseError.UPLOAD_FAILED_ERROR);
      notifyListeners();
    }

    return url;
  }

  /// Delete any [File] from Firebase Storage.
  ///
  /// The method will take in a [String] URL of the file.
  Future deleteMediaFromFirebase(String url) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      Reference ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.DELETE_FAILED_ERROR("file"));
      notifyListeners();
    }
  }
}
