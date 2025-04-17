import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:sari/utils/constants.dart';
import 'dart:convert';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ]);

  /// Get the [User] from Firebase.
  Stream<User?> get user => _auth.authStateChanges();

  /// Sign in the [User] through Firebase and
  /// the backend server.
  ///
  /// The [User] will be signed first in Firebase,
  /// then proceed to create a [Dealer].
  Future<Response> login() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? auth = await user?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth?.accessToken,
        idToken: auth?.idToken,
      );

      final data = await FirebaseAuth.instance.signInWithCredential(credential);
      return await createUser(data, dotenv.env["ADMIN_FIREBASE_TOKEN"]!);
    } catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Sign out the [User] from Firebase.
  Future<Response> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      return Response("Logout was successful.", StatusCode.OK);
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Create a [Dealer] entity in the server
  /// based on the [User] data.
  Future<Response> createUser(dynamic data, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/dealer/");
      return await post(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode(<String, String>{
            "fb_id": data.user!.uid.toString(),
            "display_name": data.user!.displayName.toString(),
            "email": data.user!.email.toString(),
            "contact_number": data.user!.phoneNumber.toString(),
            "photo_url": data.user!.photoURL.toString(),
          }));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Retrieve a single [User] from the server.
  ///
  /// The method will return a [User] object.
  Future<Response> getUser(String id, String token) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/dealer/")
          .replace(queryParameters: {"fb_id": id});
      return await get(uri, headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
      });
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Edit the contact number and chat URL of the [User].
  Future<Response> editUser(String token,
      {String? contactNumber, String? chatUrl}) async {
    try {
      var uri = Uri.parse("$BACKEND_URI/api/dealer/");
      Map<String, String> body = {};

      // Construct the request body.
      if (contactNumber.toString().isNotEmpty) {
        body["contact_number"] = contactNumber.toString();
      }

      if (chatUrl.toString().isNotEmpty) {
        body["chat_link"] = chatUrl.toString();
      }

      return await patch(uri,
          headers: <String, String>{
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: jsonEncode(body));
    } on Exception catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }

  /// Delete the [User] from Firebase Authentication.
  ///
  /// This is used when the [Dealer] entity is
  /// invalidated due to non-UP email.
  Future<Response> deleteUser(User? user) async {
    try {
      if (user != null) {
        await user.delete();
      }

      return Response("The user was successfully deleted.", StatusCode.OK);
    } catch (e) {
      return Response(e.toString(), StatusCode.INTERNAL_SERVER_ERROR);
    }
  }
}
