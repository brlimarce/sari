import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';

/// Render a widget to display a form field with an outlined border.
///
/// The [labelText] and [hintText] appears in/above the form field.
/// The [behavior] is the behavior of the floating label.
/// The [alignLabelWithHint] is a boolean that determines if the label should align with the hint.
/// The [suffixIcon] is the icon that appears at the end of the form field.
InputDecoration OutlinedFieldBorder(String labelText,
    {String? hintText,
    FloatingLabelBehavior? behavior,
    bool alignLabelWithHint = false,
    Widget? suffixIcon}) {
  return InputDecoration(
      alignLabelWithHint: alignLabelWithHint,
      border: const OutlineInputBorder(),
      labelText: labelText,
      hintText: hintText ?? labelText,
      hintStyle: const TextStyle(fontWeight: FontWeight.w400),
      suffixIcon: suffixIcon,
      floatingLabelBehavior: behavior ?? FloatingLabelBehavior.auto);
}

/// Crop an [Image] using the [ImageCropper] package.
///
/// It takes in a [String] path to the image file and returns a [CroppedFile].
Future<CroppedFile?> cropImage(String path, {CropAspectRatio? ratio}) async {
  return await ImageCropper().cropImage(
    sourcePath: path,
    aspectRatio: ratio ?? const CropAspectRatio(ratioX: 1, ratioY: 1),
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Picture Cropper',
          toolbarColor: SariTheme.primary,
          statusBarColor: SariTheme.primary,
          activeControlsWidgetColor: SariTheme.primary,
          backgroundColor: Color(SariTheme.neutralPalette.get(20)),
          toolbarWidgetColor: SariTheme.white),
    ],
  );
}

/// Remove the exception header from the error message.
///
/// The [error] is the error message from the exception.
String reformatError(String error) {
  String message = error.replaceFirst("Exception:", "");
  message = message.replaceAll("\"", "");
  message = message.replaceAll("detail:", "");
  message = message.replaceAll("{", "");
  message = message.replaceAll("}", "");
  message = message.replaceAll("[", "");
  message = message.replaceAll("]", "");
  return message.trim();
}

/// Merge separate date and time fields to parse into a [DateTime] data type.
///
/// The [date] is the date string and the [time] is the time string.
///
/// It returns a [String] of the merged end date and time.
String mergeDateTime(String date, String time) {
  return DateTime.parse("$date $time").toString();
}

/// Format the currency to the Philippine Peso format.
///
/// The [amount] is the amount to be formatted.
String formatToCurrency(double amount) {
  return NumberFormat("Php #,##0.00", "en_US").format(amount);
}

/// Truncate the text to a specific length.
///
/// The [text] is the text to be truncated and the [limit] is the length of the text.
String truncate(String text, int limit) {
  if (text.length > 14) {
    return '${text.substring(0, 14)}...';
  } else {
    return text;
  }
}

/// Return the [ButtonStyle] with a filled background color.
///
/// The [background] is the color of the button.
/// The default background color is the primary color.
ButtonStyle FillButtonStyle({Color? background}) {
  return ButtonStyle(
    elevation: WidgetStateProperty.all<double?>(0),
    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(vertical: 12)),
    backgroundColor:
        WidgetStateProperty.all<Color>(background ?? SariTheme.primary),
    shape: WidgetStateProperty.all<OutlinedBorder?>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}

/// Return the [ButtonStyle] with an outlined border.
///
/// The [border] is the color of the border.
/// The default border color is the primary color.
ButtonStyle OutlinedButtonStyle({Color? border}) {
  return ButtonStyle(
    elevation: WidgetStateProperty.all<double?>(0),
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(vertical: 12)),
    side: WidgetStateProperty.all<BorderSide>(
        BorderSide(color: border ?? SariTheme.primary, width: 1)),
    shape: WidgetStateProperty.all<OutlinedBorder?>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}

/// Return the [TextStyle] with a bold font weight.
///
/// The [color] is the foreground color.
/// The default foreground color is white.
TextStyle ButtonTextStyle({Color? color}) {
  return TextStyle(
    color: color ?? SariTheme.white,
    fontWeight: FontWeight.bold,
  );
}

/// Return the link to Google Maps based on the user's
/// current location and the destination's coordinates.
///
/// The [latitude] and [longitude] are the destination's coordinates.
String getMapLink(double latitude, double longitude) {
  return "https://www.google.com/maps?origin=My+Location&daddr=14.162110008497482,121.24135542574828";
}

/// Convert the [DateTime] to the local timezone.
///
/// The [date] is the date to be converted.
/// It should be in UTC timezone.
DateTime convertToLocalTimezone(DateTime date) {
  DateTime utc = DateTime.utc(
      date.year, date.month, date.day, date.hour, date.minute, date.second);
  return utc.toLocal();
}

/// Check if the user has an internet connection.
///
/// It returns a [Future] of a [bool] value.
Future<bool> checkInternetConnection() async {
  try {
    final url = Uri.https('google.com');
    final response = await get(url).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return Response(BaseError.SERVER_FAILED_ERROR, 408);
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
