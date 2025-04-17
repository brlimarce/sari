import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/utils/sari_theme.dart';

class AddIconButton extends StatelessWidget {
  final Function onPressed;

  const AddIconButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Color(SariTheme.greenPalette.get(97)),
        child: IconButton(
            onPressed: () {
              onPressed();
            },
            icon:
                Icon(FontAwesomeIcons.plus, size: 16, color: SariTheme.green)));
  }
}
