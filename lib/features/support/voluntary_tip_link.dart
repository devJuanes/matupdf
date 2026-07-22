import 'package:flutter/material.dart';

import '../../core/payments/paymatubyte_config.dart';
import '../../theme/app_colors.dart';
import 'voluntary_tip_sheet.dart';

/// Enlace discreto para apoyo voluntario — no modal automático.
class VoluntaryTipLink extends StatelessWidget {
  const VoluntaryTipLink({
    super.key,
    this.compact = false,
    this.lightOnDark = false,
  });

  final bool compact;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    if (!PayMatuByteConfig.isConfigured) {
      return const SizedBox.shrink();
    }

    final color = lightOnDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.textSecondaryLight;

    return TextButton.icon(
      onPressed: () => VoluntaryTipSheet.show(context),
      icon: Icon(
        Icons.coffee_outlined,
        size: compact ? 15 : 17,
        color: color,
      ),
      label: Text(
        compact ? 'Invítame un café' : '¿Te sirvió? Invítame un café (opcional)',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
