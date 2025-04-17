import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:sari/models/product_model.dart';
import 'package:sari/utils/constants.dart';

class ProductService {
  /// Add a [Product] to the server.
  Future<Response> createProduct(Product product, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/");
      return await post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(product.toJson(product)));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Add a [Product] to the user's [Bookmark] list.
  Future<Response> createBookmark(String productId, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/bookmark/");
      return await post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode({"product": productId}));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Reconstruct a 3D model of the [Product] from the server.
  Future<Response> reconstructProduct(
      String productId, List<File> files, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/reconstruct/");
      final request = MultipartRequest('POST', uri);

      // Add the files to the request body.
      request.fields['product'] = productId;
      for (File file in files) {
        request.files.add(await MultipartFile.fromPath('files', file.path));
      }

      // Add the bearer token to the request header.
      request.headers.addAll(<String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });

      final response = await request.send();
      return Response(response.reasonPhrase.toString(), response.statusCode);
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Publish the [Product] to the server.
  Future<Response> publishProduct(String id, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/reconstruct/")
          .replace(queryParameters: {"product": id});
      return await patch(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [Product] from the server,
  /// depending on the selected filters.
  ///
  /// The method will return a [List] of [Product] objects.
  /// If there is an error, the method will return an empty list.
  Future<Response> getAllProducts(String token,
      {Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/")
          .replace(queryParameters: filters);
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve a single [Product] from the server.
  ///
  /// The method will return a [Product] object.
  Future<Response> getProduct(String id, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/")
          .replace(queryParameters: {"id": id});
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [Category] from the server.
  Future<Response> getAllCategories(String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/category/");
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [PaymentMethod] from the server.
  Future<Response> getAllPaymentMethods(String token,
      {Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/payment/")
          .replace(queryParameters: filters);
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [Place] from the server.
  Future<Response> getAllPlaces(String token,
      {Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/meetup/place/")
          .replace(queryParameters: filters);
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [Schedule] from the server.
  Future<Response> getAllSchedules(
      String token, String product, DateTime startDate) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/meetup/schedule/")
          .replace(queryParameters: {
        "product": product,
        "start_date": startDate.toString(),
      });
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve [Bookmark] from the server.
  Future<Response> getBookmarks(String token,
      {Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/bookmark/")
          .replace(queryParameters: filters);
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Reopen the selling of the [Product].
  Future<Response> reopenSelling(
      String id, String token, Map<String, dynamic> data) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/");
      data["id"] = id;
      return await put(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(data));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Cancel the selling of a [Product] from the server.
  Future<Response> cancelSelling(String id, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/");
      return await patch(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode({"id": id}));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Delete the [Product] from the server.
  Future<Response> deleteProduct(String id, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/product/")
          .replace(queryParameters: {"id": id});
      return await delete(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Delete the [Bookmark] from the server.
  Future<Response> deleteBookmark(String productId, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/bookmark/")
          .replace(queryParameters: {"product": productId});
      return await delete(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }
}
