import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/animated_fade_in.dart';
import '../../../../widgets/section_header.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  static const _faqs = [
    (
      question: '¿Es gratis?',
      answer:
          'Sí, MatuPDF es completamente gratuito. Puedes combinar tantos PDFs como necesites '
          'sin pagar ni suscribirte a ningún plan.',
    ),
    (
      question: '¿Mis archivos están seguros?',
      answer:
          'Absolutamente. Todo el procesamiento ocurre localmente en tu dispositivo. '
          'Tus documentos nunca se suben a ningún servidor externo.',
    ),
    (
      question: '¿Funciona en móvil?',
      answer:
          'Sí, MatuPDF está optimizado para dispositivos móviles, tablets y escritorio. '
          'La experiencia se adapta perfectamente a cualquier pantalla.',
    ),
    (
      question: '¿Puedo combinar múltiples PDFs?',
      answer:
          'Por supuesto. Puedes seleccionar tantos archivos PDF como necesites, '
          'ordenarlos a tu gusto y combinarlos en un solo documento.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                title: 'Preguntas frecuentes',
                subtitle:
                    'Resolvemos las dudas más comunes sobre MatuPDF.',
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    for (var i = 0; i < _faqs.length; i++)
                      AnimatedFadeIn(
                        delay: Duration(milliseconds: 80 * i),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FaqTile(
                            question: _faqs[i].question,
                            answer: _faqs[i].answer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        boxShadow: _expanded ? AppColors.cardShadow(isDark: isDark) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      widget.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
