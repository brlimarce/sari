class ErrorHandler {
  late String _error;
  late bool _active;

  // Getters
  String get error => _error;
  bool get active => _active;

  ErrorHandler() {
    _error = "";
    _active = false;
  }

  /// Set the error message.
  ///
  /// The [error] is the error message.
  void set(String error) {
    _error = error;
    _active = true;
  }

  /// Clear the error message.
  void clear() {
    _error = "";
    _active = false;
  }
}
