import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';

class ProductStatus {
  static const String PROCESSING = "PROCESSING";
  static const String READY_TO_PUBLISH = "READY_TO_PUBLISH";
  static const String SCAN_FAILED = "SCAN_FAILED";
  static const String ONGOING = "ONGOING";
  static const String BID_MINE = "BID_MINE";
  static const String BID_GRAB = "BID_GRAB";
  static const String BID_STEAL = "BID_STEAL";
  static const String COMPLETED = "COMPLETED";
  static const String CANCELLED = "CANCELLED";

  static const Map<String, String> NAMES = {
    PROCESSING: "Processing",
    READY_TO_PUBLISH: "Ready to Publish",
    SCAN_FAILED: "Scan Failed",
    ONGOING: "Ongoing",
    BID_MINE: "Mine",
    BID_GRAB: "Grab",
    BID_STEAL: "Steal",
    COMPLETED: "Completed",
    CANCELLED: "Cancelled"
  };

  /// Return the background color based on the status.
  static Color getBackgroundColor(BuildContext context, String status) {
    switch (status) {
      // Bright Orange
      case PROCESSING:
      case ONGOING:
      case BID_MINE:
        return Color(SariTheme.tertiaryPalette.get(96));

      // Bright Green
      case READY_TO_PUBLISH:
      case COMPLETED:
        return Color(SariTheme.greenPalette.get(96));

      // Bright Blue
      case BID_GRAB:
        return Color(SariTheme.secondaryPalette.get(96));

      // Bright Red
      case CANCELLED:
      case SCAN_FAILED:
        return Theme.of(context).colorScheme.errorContainer;

      // Bright Purple
      case BID_STEAL:
      default:
        return Color(SariTheme.primaryPalette.get(96));
    }
  }

  /// Return the foreground color based on the status.
  static Color getForegroundColor(BuildContext context, String status) {
    switch (status) {
      // Dark Orange
      case PROCESSING:
      case ONGOING:
      case BID_MINE:
        return Color(SariTheme.tertiaryPalette.get(30));

      // Dark Green
      case READY_TO_PUBLISH:
      case COMPLETED:
        return SariTheme.green;

      // Dark Blue
      case BID_GRAB:
        return SariTheme.secondary;

      // Dark Red
      case CANCELLED:
      case SCAN_FAILED:
        return Theme.of(context).colorScheme.error;

      // Dark Purple
      case BID_STEAL:
      default:
        return SariTheme.primary;
    }
  }
}

class TransactionStatus {
  static const String ONGOING = "ONGOING";
  static const String BID_MINE = "BID_MINE";
  static const String BID_GRAB = "BID_GRAB";
  static const String BID_STEAL = "BID_STEAL";
  static const String PENDING_PAYMENT = "PENDING_PAYMENT";
  static const String PENDING_SCHEDULE = "PENDING_SCHEDULE";
  static const String READY_FOR_CONFIRMATION = "READY_FOR_CONFIRMATION";
  static const String READY_FOR_MEETUP = "READY_FOR_MEETUP";
  static const String RECEIVED = "RECEIVED";
  static const String DELIVERED = "DELIVERED";
  static const String COMPLETED = "COMPLETED";
  static const String RATED = "RATED";
  static const String CANCELLED = "CANCELLED";

  static const Map<String, String> NAMES = {
    ONGOING: "Ongoing",
    BID_MINE: "Mine",
    BID_GRAB: "Grab",
    BID_STEAL: "Steal",
    PENDING_PAYMENT: "Pending Payment",
    PENDING_SCHEDULE: "Pending Schedule",
    READY_FOR_CONFIRMATION: "Ready for Confirmation",
    READY_FOR_MEETUP: "Ready for Meetup",
    RECEIVED: "Received",
    DELIVERED: "Delivered",
    COMPLETED: "Completed",
    RATED: "Rated",
    CANCELLED: "Cancelled"
  };

  /// Return the background color based on the status.
  static Color getBackgroundColor(BuildContext context, String status) {
    switch (status) {
      // Bright Orange
      case ONGOING:
      case READY_FOR_CONFIRMATION:
      case BID_MINE:
      case RATED:
        return Color(SariTheme.tertiaryPalette.get(96));

      // Bright Green
      case COMPLETED:
        return Color(SariTheme.greenPalette.get(96));

      // Bright Blue
      case BID_GRAB:
      case PENDING_SCHEDULE:
      case DELIVERED:
        return Color(SariTheme.secondaryPalette.get(96));

      // Bright Red
      case PENDING_PAYMENT:
      case CANCELLED:
        return Theme.of(context).colorScheme.errorContainer;

      // Bright Purple
      case BID_STEAL:
      case READY_FOR_MEETUP:
      case RECEIVED:
      default:
        return Color(SariTheme.primaryPalette.get(96));
    }
  }

  /// Return the foreground color based on the status.
  static Color getForegroundColor(BuildContext context, String status) {
    switch (status) {
      // Bright Orange
      case ONGOING:
      case READY_FOR_CONFIRMATION:
      case BID_MINE:
      case RATED:
        return Color(SariTheme.tertiaryPalette.get(30));

      // Bright Green
      case COMPLETED:
        return SariTheme.green;

      // Bright Blue
      case BID_GRAB:
      case PENDING_SCHEDULE:
      case DELIVERED:
        return SariTheme.secondary;

      // Bright Red
      case PENDING_PAYMENT:
      case CANCELLED:
        return Theme.of(context).colorScheme.error;

      // Bright Purple
      case BID_STEAL:
      case READY_FOR_MEETUP:
      case RECEIVED:
      default:
        return SariTheme.primary;
    }
  }
}
