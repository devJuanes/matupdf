import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/route_helpers.dart';
import '../../theme/app_colors.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class AuthNavButton extends StatelessWidget {
  const AuthNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (auth.isAuthenticated) {
      return PopupMenuButton<String>(
        tooltip: 'Mi cuenta',
        onSelected: (value) {
          if (value == 'account') context.go(AppRoutes.account);
          if (value == 'logout') auth.signOut();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            enabled: false,
            child: Text(
              auth.user!.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const PopupMenuItem(value: 'account', child: Text('Mi cuenta')),
          const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  auth.user!.displayName.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                auth.user!.displayName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
              ),
              Icon(
                Icons.expand_more,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      );
    }

    return TextButton.icon(
      onPressed: () => context.go(
        RouteHelpers.account(redirect: GoRouterState.of(context).uri.path),
      ),
      icon: const Icon(Icons.person_outline, size: 18),
      label: const Text('Entrar'),
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      ),
    );
  }
}
