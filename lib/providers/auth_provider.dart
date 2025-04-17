import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:logger/logger.dart';
import 'package:sari/models/dealer_model.dart';
import 'package:sari/models/views/dealer_view_model.dart';
import 'package:sari/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/error_handler.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class DealerAuthProvider with ChangeNotifier {
  late AuthService _service;
  late FlutterSecureStorage _storage;
  late Logger _logger;
  late ErrorHandler error;

  User? currentUser;

  /// Get the current logged [User].
  User? get user => currentUser;

  DealerAuthProvider() {
    _service = AuthService();
    _storage = const FlutterSecureStorage();
    _logger = Logger();
    error = ErrorHandler();

    _service.user.listen((User? newUser) {
      currentUser = newUser;
      notifyListeners();
    }, onError: (e) {
      error.set(ApiError.FETCH_FAILED_ERROR("user"));
    });
  }

  /// Get the Firebase token from the secured storage.
  ///
  /// The method will return a [String] token.
  Future<String?> getFirebaseId() async {
    try {
      return await _storage.read(key: FBID_HEADER);
    } catch (e) {
      _logger.e(e.toString());
      error.set(ApiError.FETCH_FAILED_ERROR("Firebase ID", isPersonal: true));
      notifyListeners();
    }

    return null;
  }

  /// Get the [Dealer] from the server.
  ///
  /// The method will return a [Dealer] object.
  /// If there is an error, the method will return null.
  Future<DealerViewModel?> getUser(String id) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.getUser(id, token!);
      return DealerViewModel.fromJson(jsonDecode(data.body));
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.FETCH_FAILED_ERROR("user"));
      notifyListeners();
    }

    return null;
  }

  /// Edit the contact number/chat link of the [Dealer].
  ///
  /// The method will return a [Future] of [int] status code.
  Future<int> updateDealer(String? contactNumber, String? chatUrl) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      String? token = await _storage.read(key: FBID_HEADER);
      Response data = await _service.editUser(token!,
          contactNumber: contactNumber, chatUrl: chatUrl);
      return data.statusCode;
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(ApiError.UPDATE_FAILED_ERROR("contact information",
          isPersonal: true));
      notifyListeners();
    }

    return StatusCode.INTERNAL_SERVER_ERROR;
  }

  /// Sign in through Firebase and the backend server.
  ///
  /// The [Dealer] has to be created before the data
  /// is stored in a secured storage.
  ///
  /// Otherwise, the [Dealer] and [User] will be
  /// deleted from the server and Firebase.
  Future<int> login() async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      Response data = await _service.login();
      int status = data.statusCode;

      if (status != StatusCode.OK && status != StatusCode.CREATED) {
        deleteUser();
        throw Exception(jsonDecode(data.body));
      }

      Dealer dealer = Dealer.fromJson(json.decode(data.body));
      await _storage.write(key: FBID_HEADER, value: dealer.fb_id);
      return StatusCode.OK;
    } catch (e) {
      _logger.e(e.toString());
      error.set(DealerError.LOGIN_FAILED_ERROR);

      await _service.logout();
      await _storage.deleteAll();

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Sign out of the application.
  Future<int> logout() async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      await _service.logout();
      await _storage.deleteAll();

      notifyListeners();
      return StatusCode.OK;
    } catch (e) {
      _logger.e(e.toString());
      error.set(DealerError.LOGOUT_FAILED_ERROR);

      notifyListeners();
      return StatusCode.INTERNAL_SERVER_ERROR;
    }
  }

  /// Delete the [User] from Firebase.
  Future deleteUser() async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      if (user != null) await user!.delete();
      await _storage.deleteAll();
      notifyListeners();
    } catch (e) {
      _logger.e(reformatError(e.toString()));
      error.set(DealerError.LOGOUT_FAILED_ERROR);
      notifyListeners();
    }
  }

  /// Redirect to an external URL.
  ///
  /// The method will take a [String] link.
  void redirectUrl(String url) async {
    try {
      bool hasInternet = await checkInternetConnection();
      if (!hasInternet) throw Exception(BaseError.NO_CONNECTION_ERROR);

      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception(BaseError.URL_LAUNCH_ERROR);
      }
    } on Exception catch (e) {
      _logger.e(e.toString());
      error.set(BaseError.URL_LAUNCH_ERROR);
      notifyListeners();
    }
  }
}
