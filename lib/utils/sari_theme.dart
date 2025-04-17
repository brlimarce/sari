import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class SariTheme {
  // Key Colors
  static Color primary = const Color.fromRGBO(99, 91, 255, 1);
  static Color secondary = const Color.fromRGBO(10, 37, 64, 1);
  static Color tertiary = const Color.fromRGBO(255, 130, 0, 1);

  // Other Colors
  static Color white = const Color.fromRGBO(254, 254, 254, 1);
  static Color black = const Color.fromRGBO(24, 24, 27, 1);
  static Color green = const Color.fromRGBO(62, 104, 55, 1);
  static Color pink = const Color.fromRGBO(252, 77, 142, 1);
  static Color yellow = const Color.fromRGBO(245, 158, 11, 1);

  // Derived Color Palettes
  static TonalPalette primaryPalette =
      TonalPalette.fromHct(_getColor(primary.value));

  static TonalPalette secondaryPalette =
      TonalPalette.fromHct(_getColor(secondary.value));

  static TonalPalette tertiaryPalette =
      TonalPalette.fromHct(_getColor(tertiary.value));

  static TonalPalette neutralPalette =
      TonalPalette.fromHct(_getColor(black.value));

  static TonalPalette greenPalette =
      TonalPalette.fromHct(_getColor(green.value));

  static TonalPalette pinkPalette = TonalPalette.fromHct(_getColor(pink.value));

  /// Get the hue, chroma, and tone based on
  /// a value from [Color].
  static Hct _getColor(int value) {
    return Hct.fromInt(value);
  }
}
