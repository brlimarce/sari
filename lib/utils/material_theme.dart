// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sari/utils/sari_theme.dart';

ThemeData MaterialTheme(BuildContext context) {
  const double LETTER_SPACING = -0.25;
  const String INTER = "Inter";

  return ThemeData(
      brightness: Brightness.light,

      // Primary Colors
      colorScheme: ColorScheme.fromSeed(seedColor: SariTheme.primary).copyWith(
        // Secondary Colors
        secondary: SariTheme.secondary,
        onSecondary: const Color.fromRGBO(255, 255, 255, 1),

        // Tertiary Colors
        tertiary: SariTheme.tertiary,
        onTertiary: const Color.fromRGBO(255, 255, 255, 1),

        // Surface
        surface: const Color.fromRGBO(252, 248, 255, 1),
        onSurface: const Color.fromRGBO(27, 27, 33, 1),

        // Outline
        outline: const Color.fromRGBO(121, 116, 126, 1),
      ),

      // Typography
      textTheme: Theme.of(context).textTheme.copyWith(
            // Display
            displayLarge: GoogleFonts.interTextTheme().displayLarge!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w900,
                fontFamily: INTER),
            displayMedium: GoogleFonts.interTextTheme().displayMedium!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w900,
                fontFamily: INTER),
            displaySmall: GoogleFonts.interTextTheme().displaySmall!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w900,
                fontFamily: INTER),

            // Headline
            headlineLarge: GoogleFonts.interTextTheme().headlineLarge!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w900,
                fontFamily: INTER),
            headlineMedium: GoogleFonts.interTextTheme()
                .headlineMedium!
                .copyWith(
                    letterSpacing: LETTER_SPACING,
                    fontWeight: FontWeight.w800,
                    fontFamily: INTER),
            headlineSmall: GoogleFonts.interTextTheme().headlineSmall!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w900,
                fontFamily: INTER),

            // Title
            titleLarge: GoogleFonts.interTextTheme().titleLarge!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w700,
                fontFamily: INTER),
            titleMedium: GoogleFonts.interTextTheme().titleMedium!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w400,
                fontFamily: INTER),
            titleSmall: GoogleFonts.interTextTheme().titleSmall!.copyWith(
                letterSpacing: LETTER_SPACING,
                fontWeight: FontWeight.w400,
                fontFamily: INTER),

            // Body
            bodyLarge: GoogleFonts.interTextTheme()
                .bodyLarge!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),
            bodyMedium: GoogleFonts.interTextTheme()
                .bodyMedium!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),
            bodySmall: GoogleFonts.interTextTheme()
                .bodySmall!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),

            // Label
            labelLarge: GoogleFonts.interTextTheme()
                .labelLarge!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),
            labelMedium: GoogleFonts.interTextTheme()
                .labelMedium!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),
            labelSmall: GoogleFonts.interTextTheme()
                .labelSmall!
                .copyWith(letterSpacing: LETTER_SPACING, fontFamily: INTER),
          ));
}
