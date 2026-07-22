import 'package:flutter/material.dart';

import '../../core/payments/paymatubyte_config.dart';
import '../../widgets/app_button.dart';
import 'voluntary_tip_sheet.dart';

/// Botón visible para apoyo voluntario (landing, footer, etc.).
class VoluntaryTipButton extends StatelessWidget {
  const VoluntaryTipButton({
    super.key,
    this.compact = false,
    this.outlined = true,
    this.label,
  });

  final bool compact;
  final bool outlined;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (!PayMatuByteConfig.isConfigured) {
      return const SizedBox.shrink();
    }

    return AppButton(
      label: label ?? 'Invítame un café',
      icon: Icons.coffee_rounded,
      compact: compact,
      variant: outlined ? AppButtonVariant.outline : AppButtonVariant.secondary,
      onPressed: () => VoluntaryTipSheet.show(context),
    );
  }
}
