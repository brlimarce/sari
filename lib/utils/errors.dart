class BaseError {
  static const String SERVER_FAILED_ERROR = "The server failed to respond.";
  static const String FETCH_ERROR =
      "We encountered an error while fetching the data.";
  static const String NO_CONNECTION_ERROR =
      "We're having trouble connecting to the internet right now. Try again later.";
  static const String URL_LAUNCH_ERROR =
      "The link failed to launch. Try again.";
  static const String UPLOAD_FAILED_ERROR = "Upload failed. Please try again.";
}

class ApiError extends BaseError {
  static String FETCH_FAILED_ERROR(String data, {bool isPersonal = false}) {
    return "We couldn't load ${isPersonal ? "your" : "the"} $data. Please refresh the page and try again.";
  }

  static String CREATE_FAILED_ERROR(String data, {bool isPersonal = false}) {
    return "We couldn't create ${isPersonal ? "your" : "the"} $data. Please try again.";
  }

  static String UPDATE_FAILED_ERROR(String data, {bool isPersonal = false}) {
    return "Something went wrong while updating ${isPersonal ? "your" : "the"} $data. Please try again.";
  }

  static String DELETE_FAILED_ERROR(String data, {bool isPersonal = false}) {
    return "Something went wrong while deleting ${isPersonal ? "your" : "the"} $data. Please try again.";
  }
}

class DealerError extends BaseError {
  static const String LOGIN_FAILED_ERROR =
      "Login failed. Please make sure you're using a UP mail account and try again.";
  static const String LOGOUT_FAILED_ERROR = "Logout failed. Please try again.";
  static const String INVALID_PHONE_ERROR = "This phone number is invalid.";
  static const String INVALID_CHAT_URL_ERROR = "The Messenger link is invalid.";
}

class ProductError extends BaseError {
  static const String REQUIRED_ERROR = "This field is required.";
  static const String MIN_PRICE_GREATER_ERROR =
      "This should be less than the maximum price.";
  static const String MAX_PRICE_LESS_ERROR =
      "This should be greater than the minimum price.";
  static const String EMPTY_IMAGE_ERROR =
      "Please upload an image thumbnail for your product.";

  static const String MINE_GREATER_THAN_GRAB =
      "The mine price should be less than the grab price.";
  static const String GRAB_LESS_THAN_MINE =
      "The grab price should be greater than the mine price.";
  static const String STEAL_INCREMENT_ERROR =
      "The steal increment value should be divisible by 10.";
  static const String STOCK_QUANTITY_ERROR =
      "The stock quantity should be greater than 1.";
  static const String SCHEDULE_OVERLAP_ERROR =
      "This schedule overlaps with an existing one.";
  static const String END_EARLIER_ERROR = "This should be later.";
  static const String START_LATER_ERROR = "This should be earlier.";

  static const String CANCEL_FAILED_ERROR =
      "The selling failed to be canceled.";
  static const String BOOKMARK_FAILED_ERROR =
      "We failed to bookmark the product. Please try again.";
  static const String UNBOOKMARK_FAILED_ERROR =
      "We failed to unbookmark the product. Please try again.";
  static const String RECONSTRUCT_FAILED_ERROR =
      "Something went wrong while reconstructing the product. Please try again later.";
  static const String PUBLISH_FAILED_ERROR =
      "We failed to publish the product. Please try again.";
  static const String REOPEN_FAILED_ERROR =
      "We failed to reopen the product selling. Please try again.";

  static String CHARACTER_LIMIT_ERROR(int limit) {
    return "This field cannot exceed $limit characters.";
  }

  static String SELECT_ONE_ERROR(String field) {
    return "Please select at least one $field.";
  }
}

class TransactionError extends BaseError {
  static const GENERIC_ERROR =
      "We failed to process the transaction. Please try again later.";
  static const PURCHASE_FAILED_ERROR =
      "Something went wrong while purchasing the product. Please try again.";
  static const BID_FAILED_ERROR =
      "Something went wrong while bidding for the product. Please try again.";
}
