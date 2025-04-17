import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:sari/utils/sari_theme.dart';

class TransactionHeader extends StatelessWidget {
  TonalPalette palette;
  String iconPath;
  String name;
  List<InlineSpan> children;

  TransactionHeader({
    super.key,
    required this.palette,
    required this.iconPath,
    required this.name,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(palette.get(97)),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// [Icon]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                      child: Image.asset(iconPath)),

                  /// [Title and Description]
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        // Title
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Text(name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: Color(palette.get(30))))),

                        // Description
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: SariTheme.black,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                              children: children),
                        ),
                      ]))
                ])));
  }
}
