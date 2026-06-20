import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/animated_fade_in.dart';
import '../../../../widgets/section_header.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    (
      number: '01',
      icon: Icons.upload_file_rounded,
      title: 'Sube tus PDFs',
      description:
          'Arrastra tus archivos o selecciónalos desde tu dispositivo. Acepta múltiples documentos a la vez.',
    ),
    (
      number: '02',
      icon: Icons.swap_vert_rounded,
      title: 'Ordena los archivos',
      description:
          'Arrastra para reorganizar el orden de los documentos antes de combinarlos.',
    ),
    (
      number: '03',
      icon: Icons.download_rounded,
      title: 'Descarga el resultado',
      description:
          'Haz clic en combinar y descarga tu PDF unificado al instante.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: isDark ? const Color(0xFF0B1220) : AppColors.backgroundLight,
      child: ContentContainer(
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
                title: 'Cómo funciona',
                subtitle:
                    'Tres pasos simples para combinar tus documentos PDF en un solo archivo.',
              ),
              const SizedBox(height: 56),
              isMobile
                  ? Column(
                      children: [
                        for (var i = 0; i < _steps.length; i++)
                          AnimatedFadeIn(
                            delay: Duration(milliseconds: 150 * i),
                            child: _StepCard(
                              step: _steps[i],
                              isLast: i == _steps.length - 1,
                              isMobile: isMobile,
                            ),
                          ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _steps.length; i++) ...[
                          Expanded(
                            child: AnimatedFadeIn(
                              delay: Duration(milliseconds: 150 * i),
                              child: _StepCard(
                                step: _steps[i],
                                isLast: i == _steps.length - 1,
                                isMobile: isMobile,
                              ),
                            ),
                          ),
                          if (i < _steps.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                        ],
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.isLast,
    required this.isMobile,
  });

  final ({String number, IconData icon, String title, String description}) step;
  final bool isLast;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          margin: EdgeInsets.only(bottom: isMobile && !isLast ? 24 : 0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: AppColors.cardShadow(isDark: isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    step.number,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(step.icon, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(step.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(step.description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
