import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme_notifier.dart';
import '../theme/app_colors.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.isDark;

    return Tooltip(
      message: isDark ? 'Modo claro' : 'Modo oscuro',
      child: IconButton(
        onPressed: themeNotifier.toggle,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? AppColors.textPrimaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
