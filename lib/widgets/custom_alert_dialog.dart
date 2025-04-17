import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';

class CustomAlertDialog extends StatelessWidget {
  /// [Dialog Header]
  String title;
  Color? titleColor;

  IconData icon;
  Color? iconColor;
  double? iconSize;

  /// [Dialog Body]
  Widget body;
  String activeButtonLabel;
  Color? activeButtonColor;

  bool isInactiveButtonVisible = true;
  String? inactiveButtonLabel;
  Function onPressed;
  Function? onInactivePressed;

  CustomAlertDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.body,
    required this.activeButtonLabel,
    required this.onPressed,
    this.activeButtonColor,
    this.iconColor,
    this.iconSize,
    this.titleColor,
    this.isInactiveButtonVisible = true,
    this.inactiveButtonLabel,
    this.onInactivePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: titleColor ?? SariTheme.primary,
              fontWeight: FontWeight.w900)),
      content: body,
      iconPadding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      icon: Icon(icon,
          color: iconColor ?? SariTheme.tertiary, size: iconSize ?? 24),
      actions: <Widget>[
        /// [Active Button]
        TextButton(
          child: Text(activeButtonLabel.toUpperCase(),
              style: ButtonTextStyle(
                  color: activeButtonColor ?? SariTheme.primary)),
          onPressed: () async {
            onPressed();
          },
        ),

        /// [Cancel Button]
        isInactiveButtonVisible
            ? TextButton(
                child: Text(inactiveButtonLabel?.toUpperCase() ?? "CANCEL",
                    style: TextStyle(
                      color: Color(SariTheme.neutralPalette.get(60)),
                    )),
                onPressed: () {
                  onInactivePressed?.call();
                  Navigator.of(context).pop();
                },
              )
            : Container(),
      ],
    );
  }
}
