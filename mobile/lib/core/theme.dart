import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NwColors {
  static const bg = Color(0xFF07111D);
  static const bgElevated = Color(0xFF0D1A2B);
  static const panel = Color(0xFF112033);
  static const line = Color(0xFF1E334D);
  static const text = Color(0xFFE8EEF7);
  static const muted = Color(0xFF8B9BB4);
  static const accent = Color(0xFF3DD6C6);
  static const accentDim = Color(0xFF1F8F84);
  static const warn = Color(0xFFF0B429);
  static const crit = Color(0xFFFF5D6C);
  static const ok = Color(0xFF3DD68C);
  static const info = Color(0xFF7AA2FF);
}

ThemeData buildNetWatchTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NwColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: NwColors.accent,
      secondary: NwColors.info,
      surface: NwColors.panel,
      error: NwColors.crit,
      onPrimary: Color(0xFF04201C),
      onSurface: NwColors.text,
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: NwColors.text,
      displayColor: NwColors.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: NwColors.text,
        letterSpacing: -0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0A1524),
      labelStyle: const TextStyle(color: NwColors.muted),
      hintStyle: TextStyle(color: NwColors.muted.withValues(alpha: 0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NwColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NwColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NwColors.accent, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NwColors.accent,
        foregroundColor: const Color(0xFF04201C),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: NwColors.bgElevated,
      indicatorColor: NwColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? NwColors.accent : NwColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? NwColors.accent : NwColors.muted,
          size: 22,
        );
      }),
    ),
  );
}

Color statusColor(String? status) {
  switch (status) {
    case 'online':
      return NwColors.ok;
    case 'warning':
      return NwColors.warn;
    case 'critical':
    case 'down':
      return NwColors.crit;
    default:
      return NwColors.info;
  }
}

String statusLabel(String? status) {
  switch (status) {
    case 'online':
      return 'Opérationnel';
    case 'warning':
      return 'Avertissement';
    case 'critical':
      return 'Critique';
    case 'down':
      return 'Injoignable';
    default:
      return 'En attente';
  }
}
