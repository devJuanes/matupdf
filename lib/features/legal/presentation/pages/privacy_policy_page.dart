import 'package:flutter/material.dart';

import '../widgets/legal_page_layout.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const route = '/privacidad';

  @override
  Widget build(BuildContext context) {
    return LegalPageLayout(
      title: 'Política de Privacidad',
      subtitle:
          'En MatuPDF respetamos tu privacidad. Esta política explica cómo '
          'tratamos la información cuando utilizas nuestra herramienta.',
      lastUpdated: '19 de junio de 2025',
      sections: const [
        LegalSection(
          title: '1. Responsable del tratamiento',
          content:
              'El responsable del tratamiento de datos es Matu Digital S.A.S. '
              '(en adelante, "MatuPDF"), con domicilio en Colombia. '
              'Puedes contactarnos en contacto@matupdf.com para cualquier '
              'consulta relacionada con privacidad.',
        ),
        LegalSection(
          title: '2. Principio fundamental: procesamiento local',
          content:
              'MatuPDF está diseñado para procesar tus archivos PDF '
              'directamente en tu dispositivo (navegador o aplicación móvil). '
              'No subimos, almacenamos ni transmitimos tus documentos a '
              'servidores externos durante el proceso de combinación.',
        ),
        LegalSection(
          title: '3. Datos que NO recopilamos',
          content:
              'Al utilizar MatuPDF de forma estándar, no recopilamos:',
          bullets: [
            'Contenido de tus archivos PDF.',
            'Información personal identificable sin tu consentimiento.',
            'Datos de pago (el servicio es gratuito y no requiere cuenta).',
            'Historial de documentos procesados en nuestros servidores.',
          ],
        ),
        LegalSection(
          title: '4. Datos técnicos mínimos',
          content:
              'Podemos recopilar datos técnicos anónimos con fines de '
              'mejora del producto, como tipo de navegador, sistema operativo '
              'y métricas de rendimiento agregadas. Estos datos no permiten '
              'identificarte personalmente.',
        ),
        LegalSection(
          title: '5. Cookies y almacenamiento local',
          content:
              'MatuPDF puede utilizar almacenamiento local del navegador '
              'para recordar preferencias como el tema visual (modo claro/oscuro). '
              'No utilizamos cookies de seguimiento publicitario.',
        ),
        LegalSection(
          title: '6. Seguridad',
          content:
              'Implementamos buenas prácticas de seguridad en el desarrollo '
              'de la aplicación. Dado que el procesamiento es local, la '
              'seguridad de tus archivos también depende del entorno de tu '
              'dispositivo. Te recomendamos mantener tu sistema actualizado.',
        ),
        LegalSection(
          title: '7. Tus derechos',
          content:
              'Conforme a la normativa aplicable, tienes derecho a acceder, '
              'rectificar, suprimir y oponerte al tratamiento de tus datos '
              'personales cuando aplique. Para ejercer estos derechos, '
              'escríbenos a contacto@matupdf.com.',
        ),
        LegalSection(
          title: '8. Cambios en esta política',
          content:
              'Podemos actualizar esta política ocasionalmente. Publicaremos '
              'la versión revisada en esta página con la fecha de última '
              'actualización. El uso continuado del servicio implica la '
              'aceptación de los cambios.',
        ),
      ],
    );
  }
}
