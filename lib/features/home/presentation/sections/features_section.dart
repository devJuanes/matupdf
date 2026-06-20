import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../widgets/animated_fade_in.dart';
import '../../../../widgets/section_header.dart';
import '../widgets/feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const _features = [
    (
      icon: Icons.volunteer_activism_outlined,
      title: '100% gratis',
      description:
          'Combina todos los PDFs que quieras sin pagar, sin prueba limitada '
          'y sin marcas de agua en el documento final.',
    ),
    (
      icon: Icons.speed_rounded,
      title: 'Procesamiento rápido',
      description:
          'Combina documentos en segundos con un motor optimizado para máximo rendimiento.',
    ),
    (
      icon: Icons.person_off_outlined,
      title: 'Sin registro',
      description:
          'Empieza de inmediato. No necesitas crear una cuenta ni verificar tu email.',
    ),
    (
      icon: Icons.wifi_off_rounded,
      title: 'Funciona offline',
      description:
          'Todo el procesamiento ocurre localmente en tu dispositivo, sin depender de internet.',
    ),
    (
      icon: Icons.shield_outlined,
      title: 'Archivos seguros',
      description:
          'Tus documentos nunca salen de tu dispositivo. Privacidad total garantizada.',
    ),
    (
      icon: Icons.phone_android_rounded,
      title: 'Compatible con móvil',
      description:
          'Diseño responsive que funciona perfectamente en desktop, tablet y smartphone.',
    ),
    (
      icon: Icons.all_inclusive_rounded,
      title: 'Combinaciones ilimitadas',
      description:
          'Combina tantos PDFs como necesites, sin límites ni restricciones diarias.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.value(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

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
              title: 'Todo lo que necesitas',
              subtitle:
                  'Una herramienta completa para combinar PDFs con la calidad '
                  'y confianza que esperas de un producto profesional.',
            ),
            const SizedBox(height: 56),
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 24.0;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var i = 0; i < _features.length; i++)
                      SizedBox(
                        width: columns == 1
                            ? constraints.maxWidth
                            : itemWidth,
                        child: AnimatedFadeIn(
                          delay: Duration(milliseconds: 80 * i),
                          child: FeatureCard(
                            icon: _features[i].icon,
                            title: _features[i].title,
                            description: _features[i].description,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
