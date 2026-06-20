import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final bool compact;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _resolveColors(isDark);
    final enabled = widget.onPressed != null && !widget.isLoading;

    final iconSize = widget.compact ? 16.0 : 20.0;
    final hPad = widget.compact ? 16.0 : 28.0;
    final vPad = widget.compact ? 10.0 : 18.0;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(_hovered && enabled ? 1.02 : 1.0),
      decoration: BoxDecoration(
        color: enabled ? colors.background : colors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: colors.border != null ? Border.all(color: colors.border!) : null,
        boxShadow: widget.variant == AppButtonVariant.primary && enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: _hovered ? 0.45 : 0.3),
                  blurRadius: _hovered ? 20 : 12,
                  offset: Offset(0, _hovered ? 8 : 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          onHover: (hover) => setState(() => _hovered = hover),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: Row(
              mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.foreground,
                    ),
                  )
                else if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSize, color: colors.foreground),
                  SizedBox(width: widget.compact ? 8 : 10),
                ],
                Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: (widget.compact
                          ? Theme.of(context).textTheme.labelMedium
                          : Theme.of(context).textTheme.labelLarge)
                      ?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return widget.isExpanded ? SizedBox(width: double.infinity, child: child) : child;
  }

  _ButtonColors _resolveColors(bool isDark) {
    return switch (widget.variant) {
      AppButtonVariant.primary => _ButtonColors(
          background: AppColors.primary,
          foreground: Colors.white,
        ),
      AppButtonVariant.secondary => _ButtonColors(
          background: isDark ? AppColors.surfaceDark : AppColors.secondary,
          foreground: Colors.white,
        ),
      AppButtonVariant.outline => _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          border: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      AppButtonVariant.ghost => _ButtonColors(
          background: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.5)
              : AppColors.primaryLight.withValues(alpha: 0.5),
          foreground: AppColors.primary,
        ),
    };
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
