import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/animated_fade_in.dart';
import '../../../../widgets/section_header.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  static const _traditional = [
    'Requiere registro obligatorio',
    'Sube archivos a servidores externos',
    'Límites diarios de uso',
    'Interfaz sobrecargada con anuncios',
    'Procesamiento lento en la nube',
  ];

  static const _matupdf = [
    'Acceso inmediato sin cuenta',
    'Procesamiento 100% local',
    'Combinaciones ilimitadas',
    'Interfaz limpia y profesional',
    'Resultados en segundos',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return ContentContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.value(
            context: context,
            mobile: 56,
            desktop: 96,
          ),
        ),
        child: Column(
          children: [
            const SectionHeader(
              title: 'Por qué elegir MatuPDF',
              subtitle:
                  'Compara la experiencia tradicional con nuestra solución moderna.',
            ),
            const SizedBox(height: 56),
            isMobile
                ? Column(
                    children: [
                      AnimatedFadeIn(
                        child: _ComparisonCard(
                          title: 'Herramientas tradicionales',
                          items: _traditional,
                          isPositive: false,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedFadeIn(
                        delay: const Duration(milliseconds: 150),
                        child: _ComparisonCard(
                          title: 'MatuPDF',
                          items: _matupdf,
                          isPositive: true,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedFadeIn(
                          child: _ComparisonCard(
                            title: 'Herramientas tradicionales',
                            items: _traditional,
                            isPositive: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: AnimatedFadeIn(
                          delay: const Duration(milliseconds: 150),
                          child: _ComparisonCard(
                            title: 'MatuPDF',
                            items: _matupdf,
                            isPositive: true,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.items,
    required this.isPositive,
  });

  final String title;
  final List<String> items;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isPositive
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isPositive ? 2 : 1,
        ),
        boxShadow: isPositive ? AppColors.cardShadow(isDark: isDark) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.verified_rounded : Icons.history_rounded,
                color: isPositive ? AppColors.primary : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 28),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isPositive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 20,
                    color: isPositive ? AppColors.success : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
