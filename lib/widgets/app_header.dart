import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'logo.dart';
import 'theme_toggle.dart';

enum AppHeaderVariant { landing, workspace }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.variant = AppHeaderVariant.landing,
    this.onBack,
    this.actions,
  });

  final AppHeaderVariant variant;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(variant == AppHeaderVariant.workspace ? 76 : 80);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFAFBFC),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.borderDark
                : AppColors.borderLight.withValues(alpha: 0.8),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (onBack != null) ...[
                      IconButton(
                        onPressed: onBack,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        tooltip: 'Volver',
                      ),
                      const SizedBox(width: 4),
                    ],
                    const MatuLogo(size: 32),
                    if (variant == AppHeaderVariant.workspace) ...[
                      const SizedBox(width: 16),
                      Container(
                        height: 28,
                        width: 1,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Editor de PDFs',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                    const Spacer(),
                    if (actions != null) ...actions!,
                    const ThemeToggle(),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                  Color(0xFF111827),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LandingAppHeader extends StatelessWidget {
  const LandingAppHeader({
    super.key,
    required this.navLinks,
  });

  final List<Widget> navLinks;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: AppHeader(
        actions: navLinks,
      ),
    );
  }
}
