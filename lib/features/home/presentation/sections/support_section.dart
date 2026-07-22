import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/payments/paymatubyte_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../support/voluntary_tip_button.dart';
import '../../../support/voluntary_tip_link.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PayMatuByteConfig.isConfigured) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: isDark ? AppColors.surfaceDark : const Color(0xFFFFF8F5),
      child: ContentContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.value(context: context, mobile: 40, desktop: 56),
            horizontal: Responsive.value(context: context, mobile: 0, desktop: 0),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 22 : 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.surfaceDark,
                      ]
                    : [
                        Colors.white,
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.coffee_rounded,
                  size: 36,
                  color: AppColors.primary.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 14),
                Text(
                  '¿Te sirvió MatuPDF?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Es 100% gratis. Si quieres apoyar el proyecto, puedes invitarnos un café '
                  'o hacer una donación voluntaria — tú eliges el monto.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    VoluntaryTipButton(
                      compact: isMobile,
                      outlined: false,
                      label: isMobile ? 'Invítame un café' : 'Invítame un café / Donar',
                    ),
                    const VoluntaryTipLink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
