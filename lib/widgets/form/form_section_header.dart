import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sari/utils/sari_theme.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  final String emojiPath;
  final String description;

  Color? textColor;
  double? bottomMargin;

  FormSectionHeader({
    super.key,
    required this.title,
    required this.emojiPath,
    required this.description,
    this.textColor,
    this.bottomMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: textColor ?? SariTheme.primary)),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: SvgPicture.asset(emojiPath)),
          ],
        ),

        // Description
        Padding(
            padding: EdgeInsets.fromLTRB(0, 6, 0, bottomMargin ?? 36),
            child: Text(description,
                style:
                    TextStyle(color: Color(SariTheme.neutralPalette.get(50))))),
      ],
    );
  }
}
