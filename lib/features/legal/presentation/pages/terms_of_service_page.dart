import 'package:flutter/material.dart';

import '../widgets/legal_page_layout.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const route = '/terminos';

  @override
  Widget build(BuildContext context) {
    return LegalPageLayout(
      title: 'Términos de Servicio',
      subtitle:
          'Al utilizar MatuPDF, aceptas los siguientes términos y condiciones '
          'de uso de la plataforma.',
      lastUpdated: '19 de junio de 2025',
      sections: const [
        LegalSection(
          title: '1. Aceptación de los términos',
          content:
              'Al acceder y utilizar MatuPDF, aceptas cumplir con estos '
              'Términos de Servicio. Si no estás de acuerdo, te pedimos '
              'que no utilices la plataforma.',
        ),
        LegalSection(
          title: '2. Descripción del servicio',
          content:
              'MatuPDF es una herramienta gratuita que permite combinar '
              'múltiples archivos PDF en un solo documento. El procesamiento '
              'se realiza localmente en el dispositivo del usuario.',
        ),
        LegalSection(
          title: '3. Uso permitido',
          content: 'Te comprometes a utilizar MatuPDF únicamente para:',
          bullets: [
            'Combinar documentos PDF de los que tengas derecho de uso.',
            'Fines personales, educativos o profesionales legítimos.',
            'Respetar las leyes de propiedad intelectual aplicables.',
          ],
        ),
        LegalSection(
          title: '4. Uso prohibido',
          content: 'Queda estrictamente prohibido:',
          bullets: [
            'Procesar contenido ilegal, difamatorio o que viole derechos de terceros.',
            'Intentar vulnerar, descompilar o modificar el software.',
            'Utilizar la plataforma para distribuir malware o contenido dañino.',
            'Realizar ingeniería inversa con fines comerciales no autorizados.',
          ],
        ),
        LegalSection(
          title: '5. Propiedad intelectual',
          content:
              'MatuPDF, su marca, diseño, código fuente y contenidos son '
              'propiedad de Matu Digital S.A.S. o sus licenciantes. '
              'Los archivos PDF que procesas siguen siendo de tu propiedad.',
        ),
        LegalSection(
          title: '6. Limitación de responsabilidad',
          content:
              'MatuPDF se proporciona "tal cual". No garantizamos que el '
              'servicio esté libre de errores en todo momento. Matu Digital '
              'no será responsable por pérdida de datos, daños indirectos '
              'o interrupciones derivadas del uso de la herramienta. '
              'Recomendamos conservar copias de respaldo de tus documentos.',
        ),
        LegalSection(
          title: '7. Disponibilidad del servicio',
          content:
              'Nos reservamos el derecho de modificar, suspender o '
              'descontinuar cualquier aspecto del servicio en cualquier '
              'momento, con o sin previo aviso, para mejoras técnicas '
              'o mantenimiento.',
        ),
        LegalSection(
          title: '8. Ley aplicable',
          content:
              'Estos términos se rigen por las leyes de la República de '
              'Colombia. Cualquier disputa será sometida a los tribunales '
              'competentes de Colombia.',
        ),
        LegalSection(
          title: '9. Contacto',
          content:
              'Para preguntas sobre estos términos, contáctanos en '
              'contacto@matupdf.com o soporte@matupdf.com.',
        ),
      ],
    );
  }
}
