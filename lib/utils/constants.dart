import 'package:flutter_dotenv/flutter_dotenv.dart';

// URI for the backend server.
final String BACKEND_URI = dotenv.env["BACKEND_URI"]!;
final String FLASK_URI = dotenv.env["FLASK_URI"]!;
const String FBID_HEADER = "firebase_id";

const Map<String, String> SELLING_TYPE = {
  "FOR_BIDDING": "For Bidding",
  "RECURRENT_SELLING": "Recurrent Selling",
};

final RegExp MESSENGER_REGEXP =
    RegExp(r"^(https:\/\/m\.me\/)([a-zA-Z0-9\.]+)(\?ref=[a-zA-Z0-9\.]+)?\/?$");
