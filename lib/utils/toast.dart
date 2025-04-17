import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:toastification/toastification.dart';

class ToastAlert {
  static void error(BuildContext context, String message, {String? title}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(title ?? "Oh no!",
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.red)),
          description: Text(message),
          icon: const FaIcon(FontAwesomeIcons.circleExclamation,
              color: Colors.red),
          closeOnClick: true,
          pauseOnHover: true);
    });
  }

  static void success(BuildContext context, String message, {String? title}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          title: Text(title ?? "Success!",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: SariTheme.green)),
          description: Text(message),
          icon: FaIcon(
            FontAwesomeIcons.solidCircleCheck,
            color: SariTheme.green,
          ),
          closeOnClick: true,
          pauseOnHover: true);
    });
  }
}
