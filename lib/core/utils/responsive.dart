import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppConstants.breakpointMobile) return ScreenSize.mobile;
    if (width < AppConstants.breakpointTablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  static double sectionPadding(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile => AppConstants.sectionPaddingMobile,
      ScreenSize.tablet => AppConstants.sectionPaddingTablet,
      ScreenSize.desktop => AppConstants.sectionPaddingDesktop,
    };
  }

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    return switch (of(context)) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? desktop,
      ScreenSize.desktop => desktop,
    };
  }
}
