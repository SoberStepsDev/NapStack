import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralna konfiguracja motywu NapStack.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.kBgBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kAccent,
        secondary: AppColors.kAccentDim,
        surface: AppColors.kBgCard,
        onPrimary: AppColors.kBgDeep,
        onSecondary: AppColors.kTextPrimary,
        onSurface: AppColors.kTextPrimary,
        error: AppColors.kError,
        outline: AppColors.kBorder,
      ),

      // System UI — status bar przeźroczysta, ikony jasne
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: _syne(18, AppColors.kTextPrimary, FontWeight.w600),
        iconTheme: const IconThemeData(color: AppColors.kTextSecondary),
      ),

      // NavigationBar (bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.kBgCard,
        indicatorColor: AppColors.kBgElevated,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return _dmSans(
            11,
            active ? AppColors.kAccent : AppColors.kTextMuted,
            FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.kAccent : AppColors.kTextMuted,
            size: 22,
          );
        }),
        elevation: 0,
        height: 68,
      ),

      // Text
      textTheme: _buildTextTheme(),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.kBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.kBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialogi
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.kBgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _syne(18, AppColors.kTextPrimary, FontWeight.w600),
        contentTextStyle: _dmSans(15, AppColors.kTextSecondary, FontWeight.w400),
      ),

      // ElevatedButton — CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kAccent,
          foregroundColor: AppColors.kBgDeep,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _syne(16, AppColors.kBgDeep, FontWeight.w700),
          elevation: 0,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kAccent,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.kAccent, width: 1.5),
          textStyle: _syne(16, AppColors.kAccent, FontWeight.w600),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kAccent,
          textStyle: _dmSans(14, AppColors.kAccent, FontWeight.w500),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.kBorder,
        thickness: 1,
        space: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.kAccent,
        foregroundColor: AppColors.kBgDeep,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.kBgCard,
        modalBackgroundColor: AppColors.kBgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.kBgElevated,
        selectedColor: AppColors.kAccentGlow,
        labelStyle: _dmSans(13, AppColors.kTextSecondary, FontWeight.w500),
        side: const BorderSide(color: AppColors.kBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.kBgElevated,
        contentTextStyle: _dmSans(14, AppColors.kTextPrimary, FontWeight.w400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: AppColors.kTextPrimary,
        iconColor: AppColors.kTextSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  static TextTheme _buildTextTheme() => TextTheme(
    // Syne — headings
    displayLarge:  _syne(57, AppColors.kTextPrimary, FontWeight.w700),
    displayMedium: _syne(45, AppColors.kTextPrimary, FontWeight.w700),
    displaySmall:  _syne(36, AppColors.kTextPrimary, FontWeight.w700),
    headlineLarge: _syne(32, AppColors.kTextPrimary, FontWeight.w600),
    headlineMedium:_syne(28, AppColors.kTextPrimary, FontWeight.w600),
    headlineSmall: _syne(24, AppColors.kTextPrimary, FontWeight.w600),
    titleLarge:    _syne(22, AppColors.kTextPrimary, FontWeight.w600),
    titleMedium:   _syne(16, AppColors.kTextPrimary, FontWeight.w600),
    titleSmall:    _syne(14, AppColors.kTextPrimary, FontWeight.w600),
    // DM Sans — body
    bodyLarge:     _dmSans(16, AppColors.kTextPrimary,    FontWeight.w400),
    bodyMedium:    _dmSans(14, AppColors.kTextSecondary,  FontWeight.w400),
    bodySmall:     _dmSans(12, AppColors.kTextMuted,      FontWeight.w400),
    labelLarge:    _dmSans(14, AppColors.kTextPrimary,    FontWeight.w500),
    labelMedium:   _dmSans(12, AppColors.kTextSecondary,  FontWeight.w500),
    labelSmall:    _dmSans(11, AppColors.kTextMuted,      FontWeight.w500),
  );

  static TextStyle _syne(double size, Color color, FontWeight weight) =>
      GoogleFonts.syne(fontSize: size, color: color, fontWeight: weight, height: 1.2);

  static TextStyle _dmSans(double size, Color color, FontWeight weight) =>
      GoogleFonts.dmSans(fontSize: size, color: color, fontWeight: weight, height: 1.4);
}
