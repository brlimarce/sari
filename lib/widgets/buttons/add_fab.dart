import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/views/products/product_form.dart';

class AddFab extends StatelessWidget {
  const AddFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: SariTheme.primary,
      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          0.5),
      onPressed: () async {
        context.push(ProductFormView.route);
      },
      child: FaIcon(FontAwesomeIcons.cartPlus, color: SariTheme.white),
    );
  }
}
