import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/home_view.dart';

class LoginView extends StatelessWidget {
  static const route = '/login';

  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DealerAuthProvider>(builder: (context, provider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      if (provider.error.active) {
        ToastAlert.error(context, provider.error.error);
        provider.error.clear();
      }

      return Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/login_bg.png"),
                      fit: BoxFit.cover)),
              child: Center(
                  child: SingleChildScrollView(
                      child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 72),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/logo/logo_white.png",
                                width: 20, height: 20),
                            const SizedBox(width: 8),
                            Text("SARI",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: SariTheme.white,
                                        fontWeight: FontWeight.w900))
                          ])),

                  // Body
                  Column(
                    children: [
                      // Icon
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: Image.asset("assets/shopping_cart.png",
                              fit: BoxFit.contain)),

                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Shop in 3D",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(color: SariTheme.white)),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: SvgPicture.asset(
                                "assets/svg_icons/emoji_sparkles.svg",
                              ))
                        ],
                      ),

                      // Description
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: Text(
                            "Embrace and transform your online shopping experience with augmented reality!",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Color(
                                        SariTheme.neutralPalette.get(96))),
                            textAlign: TextAlign.center,
                          ))
                    ],
                  ),

                  // Login Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              context.loaderOverlay.show();
                              int status = await context
                                  .read<DealerAuthProvider>()
                                  .login();

                              if (status == StatusCode.OK) {
                                if (!context.mounted) return;
                                context.replace(HomeView.route);
                              }
                            },
                            icon: FaIcon(FontAwesomeIcons.google,
                                size: 16, color: SariTheme.primary),
                            style: FillButtonStyle(background: SariTheme.white),
                            label: Text(
                              "Sign in with Google",
                              style: ButtonTextStyle(color: SariTheme.primary),
                            ))),
                  )
                ],
              )))));
    });
  }
}
