import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:sari/utils/constants.dart';

class TransactionService {
  /// Add a [Transaction] to the server for
  /// products that are of type [RECURRENT SELLING].
  Future<Response> createPurchase(
      String productId, int qty, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/purchase/");
      return await post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(<String, dynamic>{
            "product": productId,
            "qty": qty,
          }));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Add a [Transaction] to the server for
  /// products that are of type [FOR BIDDING].
  Future<Response> createBid(String productId, String token,
      {double? bid}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/bid/");
      return await post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(bid == null
              ? <String, dynamic>{"product": productId}
              : <String, dynamic>{
                  "product": productId,
                  "bid_amount": bid,
                }));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Create a [Review] for the [Transaction].
  Future<Response> createReview(String token, Map<String, dynamic> data) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/review/");
      return post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(data));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve the [Review] of the [Transaction].
  Future<Response> getReviews(String token, String productId) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/review/").replace(
        queryParameters: <String, String>{"product": productId},
      );

      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve the highest [Transaction] from the database.
  Future<Response> getHighestBids(String productId, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/bid/").replace(
        queryParameters: <String, String>{"product": productId},
      );

      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve all [Transaction] from the database.
  Future<Response> getAllTransactions(String token,
      {Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/transaction/")
          .replace(queryParameters: filters);
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token"
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Manage and process the meetup of the [Transaction].
  /// This will update some fields, depending on its status.
  Future<Response> manageMeetup(String token, String id, String product,
      String user, Map<String, dynamic> data) async {
    try {
      // Attach the arguments to the body.
      data["id"] = id;
      data["product"] = product;
      data["user"] = user;

      // Execute the request.
      var uri = Uri.parse("$BACKEND_URI/api/transaction/");
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
}
