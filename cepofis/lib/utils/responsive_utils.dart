import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static double getCardPadding(BuildContext context) {
    return isSmallPhone(context) ? 8.0 : 16.0;
  }

  static double getIconSize(BuildContext context) {
    return isSmallPhone(context) ? 20.0 : 24.0;
  }

  static double getTitleFontSize(BuildContext context) {
    return isSmallPhone(context) ? 16.0 : 20.0;
  }

  static double getSubtitleFontSize(BuildContext context) {
    return isSmallPhone(context) ? 12.0 : 14.0;
  }

  static double getChipPadding(BuildContext context) {
    return isSmallPhone(context) ? 4.0 : 8.0;
  }

  static double getChipFontSize(BuildContext context) {
    return isSmallPhone(context) ? 10.0 : 12.0;
  }
} 