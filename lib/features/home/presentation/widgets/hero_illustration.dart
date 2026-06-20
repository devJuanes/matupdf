import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';

class HeroIllustration extends StatefulWidget {
  const HeroIllustration({super.key});

  @override
  State<HeroIllustration> createState() => _HeroIllustrationState();
}

class _HeroIllustrationState extends State<HeroIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = Responsive.value(
      context: context,
      mobile: 280.0,
      tablet: 340.0,
      desktop: 420.0,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value * 8 - 4),
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size * 0.85,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: size * 0.08,
              left: size * 0.12,
              child: _PdfCard(
                label: 'Report.pdf',
                pages: '12 pág.',
                rotation: -0.08,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                isDark: isDark,
              ),
            ),
            Positioned(
              top: size * 0.22,
              right: size * 0.05,
              child: _PdfCard(
                label: 'Invoice.pdf',
                pages: '3 pág.',
                rotation: 0.06,
                color: isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9),
                isDark: isDark,
                highlighted: true,
              ),
            ),
            Positioned(
              bottom: size * 0.05,
              left: size * 0.2,
              child: _MergedBadge(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfCard extends StatelessWidget {
  const _PdfCard({
    required this.label,
    required this.pages,
    required this.rotation,
    required this.color,
    required this.isDark,
    this.highlighted = false,
  });

  final String label;
  final String pages;
  final double rotation;
  final Color color;
  final bool isDark;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: highlighted
                ? AppColors.primary.withValues(alpha: 0.4)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: highlighted ? 2 : 1,
          ),
          boxShadow: AppColors.cardShadow(isDark: isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: highlighted
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: highlighted ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(pages, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergedBadge extends StatelessWidget {
  const _MergedBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.merge_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(
            'Merged.pdf',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
