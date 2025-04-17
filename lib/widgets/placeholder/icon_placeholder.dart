import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';

class IconPlaceholder extends StatelessWidget {
  final String iconPath;
  final String title;
  final String message;
  final double? topMargin;

  const IconPlaceholder({
    super.key,
    required this.iconPath,
    required this.title,
    required this.message,
    this.topMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// [Placeholder Image]
          Padding(
              padding: EdgeInsets.fromLTRB(0, topMargin ?? 52, 0, 0),
              child: Image.asset(iconPath, height: 100)),

          /// [Placeholder Header]
          Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
              child: Text(title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Color(SariTheme.neutralPalette.get(24))))),

          /// [Placeholder Message]
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Color(SariTheme.neutralPalette.get(50)))))
        ]);
  }
}
