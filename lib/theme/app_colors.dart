import 'package:flutter/material.dart';

/// Centralised color palette for the whole app. Every screen and widget
/// pulls its colors from here so the design stays consistent as new pages
/// are added.
class AppColors {
  AppColors._(); // namespace only, never instantiated

  static const Color sidebarBg = Color(0xFF0B1252);
  static const Color cardNavyDark = Color(0xFF0A1252);
  static const Color cardNavyLight = Color(0xFF1B2478);
  static const Color pageBackground = Color(0xFFF5F3EE);
  // The soft off-white "panel" that frames every page's content, sitting
  // between the cream page background and the pure-white cards inside it.
  static const Color panelBackground = Color(0xFFFCFBF8);
  static const Color gold = Color(0xFFC9A24A);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF7A7A88);
  static const Color green = Color(0xFF2FB344);
  static const Color dangerRed = Color(0xFFD64545);
  static const Color warningAmber = Color(0xFFC98A1B);
  static const Color chartBlueDark = Color(0xFF10184F);
  static const Color chartBlueMed = Color(0xFF3247C5);
  static const Color chartBlueLight = Color(0xFF6C86FF);
  static const Color chartGray = Color(0xFFB7B7C0);
  static const Color borderLight = Color(0xFFE6E3DA);
  static const Color chipBackground = Color(0xFFEFECE3);
}
