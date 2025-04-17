import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SmallErrorPlaceholder extends StatelessWidget {
  String? error;
  double? bottomMargin;

  SmallErrorPlaceholder({super.key, this.error, this.bottomMargin});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 32, 0, bottomMargin ?? 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// [Error Icon]
              Icon(FontAwesomeIcons.circleExclamation,
                  size: 16, color: Theme.of(context).colorScheme.error),

              /// [Error Message]
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Text(
                      error ?? "The data could not be loaded. Try again.",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)))
            ]));
  }
}
