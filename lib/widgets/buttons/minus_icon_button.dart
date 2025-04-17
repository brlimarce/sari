import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MinusIconButton extends StatelessWidget {
  final Function onPressed;

  const MinusIconButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: IconButton(
            onPressed: () {
              onPressed();
            },
            icon: Icon(FontAwesomeIcons.minus,
                size: 16, color: Theme.of(context).colorScheme.error)));
  }
}
