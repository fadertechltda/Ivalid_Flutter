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
}
