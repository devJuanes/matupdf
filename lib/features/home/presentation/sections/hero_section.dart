import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/animated_fade_in.dart';
import '../../../support/voluntary_tip_button.dart';
import '../../../../widgets/app_button.dart';
import '../widgets/hero_illustration.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onSelectPdfs,
    required this.onScrollToMerge,
    this.onEditPdf,
  });

  final VoidCallback onSelectPdfs;
  final VoidCallback onScrollToMerge;
  final VoidCallback? onEditPdf;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.backgroundDark,
                  AppColors.backgroundDark.withValues(alpha: 0.95),
                ]
              : [
                  AppColors.backgroundLight,
                  Colors.white,
                ],
        ),
      ),
      child: ContentContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.value(
              context: context,
              mobile: 48,
              tablet: 64,
              desktop: 96,
            ),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeroContent(context, isMobile: true),
                    const SizedBox(height: 48),
                    const AnimatedFadeIn(
                      delay: Duration(milliseconds: 200),
                      child: HeroIllustration(),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildHeroContent(context, isMobile: false),
                    ),
                    const SizedBox(width: 48),
                    const Expanded(
                      flex: 5,
                      child: AnimatedFadeIn(
                        delay: Duration(milliseconds: 200),
                        child: HeroIllustration(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context, {required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedFadeIn(
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          _Badge(isDark: isDark),
          const SizedBox(height: 24),
          Text(
            'Combina PDFs\ngratis al instante',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: Responsive.value(
                    context: context,
                    mobile: 36,
                    tablet: 44,
                    desktop: 52,
                  ),
                  height: 1.08,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            'Une múltiples documentos PDF en un solo archivo. '
            'Herramienta 100% gratuita, sin registro ni marcas de agua.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: Responsive.value(
                    context: context,
                    mobile: 16,
                    desktop: 18,
                  ),
                ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: const [
              _BenefitChip(
                icon: Icons.volunteer_activism_outlined,
                label: '100% gratis',
              ),
              _BenefitChip(icon: Icons.bolt_rounded, label: 'Ultra rápido'),
              _BenefitChip(
                icon: Icons.lock_outline_rounded,
                label: '100% privado',
              ),
              _BenefitChip(
                icon: Icons.devices_rounded,
                label: 'Web y móvil',
              ),
            ],
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: [
              AppButton(
                label: 'Seleccionar PDFs',
                icon: Icons.upload_file_rounded,
                onPressed: onSelectPdfs,
              ),
              if (onEditPdf != null)
                AppButton(
                  label: 'Editar PDF',
                  icon: Icons.edit_document,
                  variant: AppButtonVariant.secondary,
                  onPressed: onEditPdf,
                ),
              AppButton(
                label: isMobile ? 'Ver herramienta' : 'Arrastra archivos aquí',
                icon: Icons.swipe_down_alt_rounded,
                variant: AppButtonVariant.outline,
                onPressed: onScrollToMerge,
              ),
              VoluntaryTipButton(
                compact: isMobile,
                label: isMobile ? 'Invítame un café' : 'Apoyar con un café',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Gratis para siempre · Sin registro',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
