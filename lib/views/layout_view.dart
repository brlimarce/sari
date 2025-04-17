// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/views/dealers/login_view.dart';
import 'package:sari/widgets/buttons/add_fab.dart';
import 'package:sari/widgets/bottom_navbar.dart';

/// Render the trailing actions for the [AppBar].
///
/// It takes a [BuildContext] and an optional [bool] parameter to
/// indicate if the colors should be inverted.
List<IconButton> renderActions(BuildContext context, {bool inverted = false}) {
  return <IconButton>[
    // TODO: Notifications

    // Logout
    IconButton(
      icon: FaIcon(FontAwesomeIcons.rightFromBracket,
          size: 20,
          color: inverted
              ? Color(SariTheme.neutralPalette.get(84))
              : Color(SariTheme.neutralPalette.get(64))),
      onPressed: () async {
        context.loaderOverlay.show();
        int status = await context.read<DealerAuthProvider>().logout();

        if (status == StatusCode.OK) {
          if (!context.mounted) return;
          context.replace(LoginView.route);
        }
      },
    ),
  ];
}

class LayoutView extends StatelessWidget {
  Widget child;
  int page;
  bool implied = true;

  LayoutView(
      {super.key,
      required this.child,
      required this.page,
      this.implied = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(SariTheme.primaryPalette.get(96)),
          title: Image.asset("assets/logo/logo.png", width: 32, height: 32),
          iconTheme:
              IconThemeData(color: Color(SariTheme.neutralPalette.get(50))),
          automaticallyImplyLeading: implied,
          centerTitle: true,
          actions: renderActions(context)),
      backgroundColor: Color(SariTheme.primaryPalette.get(98)),
      bottomNavigationBar: BottomNavbar(page: page),
      floatingActionButton: const AddFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: child,
    );
  }
}
