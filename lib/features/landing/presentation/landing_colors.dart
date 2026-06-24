import 'package:flutter/material.dart';
import 'package:sathya_landing/core/theme/app_colors.dart';

/// Landing page palette — aliases [AppColors] so the website matches the
/// user and admin apps.
abstract final class LandingColors {
  static const burgundy = AppColors.textColor;
  static const burgundyDark = AppColors.bgGradientMiddle;
  static const gold = AppColors.gradientEnd;
  static const goldMuted = AppColors.chakraOverlayColor;
  static const cream = AppColors.appBgColor;
  static const creamCard = AppColors.inputBorderColor;
  static const textBody = AppColors.secondary;
  static const navInactive = AppColors.secondary;
  static const primary = AppColors.primary;
  static const white = AppColors.white;

  /// Header nav + footer background
  static const headerFooterBg = Color(0xFFE45F0B);

  /// Mockup section backgrounds
  static const sectionCoreFeatures = Color(0xFFFFF9F0);
  static const sectionStoreWorks = AppColors.white;
  static const sectionCatalogue = Color(0xFFFAF4EA);

  /// Ayurveda promo card (reference mockup)
  static const ayurvedaCardBg = Color(0xFFFDF9F0);
  static const ayurvedaGreen = Color(0xFF35522B);
  static const ayurvedaGreenDark = Color(0xFF2D4628);
  static const ayurvedaText = Color(0xFF4A5C48);
  static const ayurvedaBorder = Color(0xFFE5D9C8);
  static const ayurvedaDecor = Color(0xFFD4C4A8);

  static const accentGradient = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const warmAccentGradient = LinearGradient(
    colors: [AppColors.gradientEnd, AppColors.chakraOverlayColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bannerGradient = LinearGradient(
    colors: [AppColors.bgGradientMiddle, AppColors.gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const phoneHeaderGradient = LinearGradient(
    colors: [AppColors.textColor, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
