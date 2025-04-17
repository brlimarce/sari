import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sari/firebase_options.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/context/product_form_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/material_theme.dart';
import 'package:sari/utils/router.dart';
import 'package:sari/utils/sari_theme.dart';

List<CameraDescription> cameras = [];

void main() async {
  // Load the environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Listen for changes in Firebase authentication state.
  GoRouter router = RouterService().router;
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    router.refresh();
  });

  // Initialize the device's cameras.
  cameras = await availableCameras();

  // Disable fetching the fonts from the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => DealerAuthProvider()),
    ChangeNotifierProvider(create: (context) => ProductProvider()),
    ChangeNotifierProvider(create: (context) => ProductFormProvider()),
    ChangeNotifierProvider(create: (context) => TransactionProvider()),
  ], child: MyApp(router: router)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
        overlayColor: Colors.black.withOpacity(0.25),
        overlayWidgetBuilder: (_) {
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
              child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                      color: SariTheme.white, size: 56)));
        },
        child: MaterialApp.router(
          title: 'SARI',
          theme: MaterialTheme(context),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ));
  }
}
