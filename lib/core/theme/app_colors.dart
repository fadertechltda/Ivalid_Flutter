import 'package:flutter/material.dart';

/// Cores do design system Ivalid — espelhando o tema Kotlin/Compose original
class AppColors {
  AppColors._();

  // ─── Primárias (Vermelho) ───
  static const Color redPrimary = Color(0xFFE63946);
  static const Color redPrimaryDark = Color(0xFFD62828);
  static const Color redSecondary = Color(0xFFFF6B6B);

  // ─── Acentos ───
  static const Color greenAccent = Color(0xFF2A9D8F);
  static const Color greenAccentDark = Color(0xFF264653);
  static const Color yellowAccent = Color(0xFFE9C46A);

  // ─── Light Theme ───
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF212529);
  static const Color outlineLight = Color(0xFFDEE2E6);
  static const Color grayChip = Color(0xFFF1F3F5);

  // ─── Dark Theme ───
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onBackgroundDark = Color(0xFFF8F9FA);
  static const Color outlineDark = Color(0xFF495057);
  static const Color grayChipDark = Color(0xFF2A2C2E);
}

/// Tokens de cor que seguem o tema ativo (claro/escuro).
///
/// As telas usam estes getters em vez das constantes `*Light`, garantindo que
/// o modo escuro funcione sem duplicar widgets.
extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Fundo de tela (Scaffold).
  Color get bg =>
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;

  /// Fundo de cards, sheets e diálogos.
  Color get surface =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;

  /// Cor de texto/ícone principal.
  Color get onBg =>
      isDarkMode ? AppColors.onBackgroundDark : AppColors.onBackgroundLight;

  /// Bordas e divisores.
  Color get outline =>
      isDarkMode ? AppColors.outlineDark : AppColors.outlineLight;

  /// Fundo de chips e campos preenchidos.
  Color get chipBg => isDarkMode ? AppColors.grayChipDark : AppColors.grayChip;

  /// Sombra dos cards — no escuro a sombra precisa ser mais densa para aparecer.
  Color get cardShadow =>
      Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05);

  /// Texto principal com opacidade.
  Color onBgAlpha(double alpha) => onBg.withValues(alpha: alpha);

  /// Fundo suave derivado de uma cor de destaque (badges, status, níveis).
  Color softBg(Color color) =>
      isDarkMode ? color.withValues(alpha: 0.18) : color.withValues(alpha: 0.10);

  /// Clareia cores de destaque escuras no tema escuro para manter o contraste.
  Color accent(Color color) =>
      isDarkMode ? Color.lerp(color, Colors.white, 0.35)! : color;
}
