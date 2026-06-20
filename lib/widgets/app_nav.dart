import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/responsive.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'auth_nav_button.dart';

class AppNav extends StatelessWidget {
  const AppNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavLink(
          label: 'Inicio',
          route: AppRoutes.home,
          currentRoute: currentRoute,
        ),
        const SizedBox(width: 8),
        _NavLink(
          label: 'Características',
          route: AppRoutes.home,
          currentRoute: currentRoute,
          fragment: 'caracteristicas',
        ),
        const SizedBox(width: 8),
        _NavLink(
          label: 'FAQ',
          route: AppRoutes.home,
          currentRoute: currentRoute,
          fragment: 'faq',
        ),
        _NavLink(
          label: 'Contacto',
          route: AppRoutes.contact,
          currentRoute: currentRoute,
        ),
        const SizedBox(width: 8),
        const AuthNavButton(),
        const SizedBox(width: 8),
        AppButton(
          label: 'Combinar PDFs',
          icon: Icons.merge_type_rounded,
          compact: true,
          onPressed: () => context.go(AppRoutes.merge),
        ),
      ],
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.route,
    required this.currentRoute,
    this.fragment,
  });

  final String label;
  final String route;
  final String currentRoute;
  final String? fragment;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = widget.currentRoute == widget.route && widget.fragment == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: () {
          if (widget.fragment != null) {
            context.go('${widget.route}#${widget.fragment}');
          } else {
            context.go(widget.route);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: isActive || _hovered
              ? AppColors.primary
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
