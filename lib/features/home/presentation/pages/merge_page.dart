import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/auth_nav_button.dart';
import '../controllers/merge_controller.dart';
import '../widgets/pdf_merge_workspace.dart';

class MergePage extends StatefulWidget {
  const MergePage({super.key});

  @override
  State<MergePage> createState() => _MergePageState();
}

class _MergePageState extends State<MergePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleMergeQueryParam());
  }

  void _handleMergeQueryParam() {
    if (!mounted) return;
    final params = GoRouterState.of(context).uri.queryParameters;
    if (params['merge'] != '1') return;

    context.read<MergeController>().scheduleMergeAfterAuth();
    context.go(AppRoutes.merge);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = Responsive.isDesktop(context) ||
        MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
        variant: AppHeaderVariant.workspace,
        onBack: () => context.go(AppRoutes.home),
        actions: const [AuthNavButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.value(context: context, mobile: 12, desktop: 24),
                0,
                Responsive.value(context: context, mobile: 12, desktop: 24),
                Responsive.value(context: context, mobile: 12, desktop: 20),
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 280, child: _SidePanel(isWide: true)),
                        const SizedBox(width: 20),
                        const Expanded(child: PdfMergeWorkspace()),
                      ],
                    )
                  : const PdfMergeWorkspace(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<MergeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF111827), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.value(context: context, mobile: 16, desktop: 28),
          16,
          Responsive.value(context: context, mobile: 16, desktop: 28),
          18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Herramienta',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (controller.hasFiles) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${controller.files.length} archivo${controller.files.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Combinar PDFs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arrastra, ordena y combina. Todo ocurre en tu navegador.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<MergeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppColors.cardShadow(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pasos',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _StepItem(
            number: 1,
            title: 'Sube tus PDFs',
            subtitle: 'Arrastra o selecciona archivos',
            active: !controller.hasFiles,
            done: controller.hasFiles,
          ),
          _StepItem(
            number: 2,
            title: 'Organiza',
            subtitle: 'Ordena, rota o duplica',
            active: controller.hasFiles && !controller.canMerge,
            done: controller.canMerge,
          ),
          _StepItem(
            number: 3,
            title: 'Combina',
            subtitle: 'Descarga el PDF final',
            active: controller.canMerge,
            done: controller.mergedOutputPath != null,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tus archivos no salen de tu dispositivo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.done,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = done
        ? AppColors.success
        : active
            ? AppColors.primary
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withValues(alpha: 0.15)
                  : active
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: done
                  ? Icon(Icons.check_rounded, size: 16, color: color)
                  : Text(
                      '$number',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: active || done
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight)
                            : null,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
