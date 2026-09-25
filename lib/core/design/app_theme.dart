import 'package:flutter/material.dart';

import 'app_layout_tokens.dart';

abstract final class AppTheme {
  // Replace this one seed and the semantic roles remain consistent.
  static const _seed = Color(0xFF356A83);

  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      extensions: const [AppLayoutTokens.standard],
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppLayoutTokens.standard.radiusMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppLayoutTokens.standard.radiusSm,
          ),
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(88, 48))),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(88, 48))),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(88, 48))),
      ),
    );
  }
}
