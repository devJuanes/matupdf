import '../constants/app_constants.dart';

class SeoMeta {
  const SeoMeta({
    required this.title,
    required this.description,
    required this.keywords,
    required this.path,
    this.robots = 'index, follow',
  });

  final String title;
  final String description;
  final String keywords;
  final String path;
  final String robots;

  String get canonical => '${AppConstants.siteUrl}$path';
}

class SeoCatalog {
  SeoCatalog._();

  static const _baseKeywords =
      'matupdf, pdf online, herramientas pdf gratis, pdf sin registro, pdf privado';

  static final Map<String, SeoMeta> byPath = {
    AppRoutes.home: const SeoMeta(
      title: 'MatuPDF — Combinar y editar PDFs online gratis | Sin registro',
      description:
          'Combina, une y edita PDFs gratis en el navegador. Sin registro, sin marcas de agua '
          'y procesamiento 100% local. Herramientas para unir, rotar, firmar y anotar PDFs.',
      keywords:
          'combinar pdf, unir pdf, editar pdf, merge pdf, combinar pdf online gratis, '
          'unir pdf gratis, editar pdf online, firmar pdf, rotar pdf, juntar pdf, $_baseKeywords',
      path: AppRoutes.home,
    ),
    AppRoutes.merge: const SeoMeta(
      title: 'Combinar PDFs online gratis — MatuPDF',
      description:
          'Une varios archivos PDF en uno solo. Ordena páginas, rota y descarga al instante. '
          'Gratis, sin registro y sin subir tus archivos a servidores.',
      keywords:
          'combinar pdf, unir pdf, merge pdf, juntar pdf, combinar pdf online gratis, '
          'unir archivos pdf, pdf merger, $_baseKeywords',
      path: AppRoutes.merge,
    ),
    AppRoutes.edit: const SeoMeta(
      title: 'Editar PDF online gratis — MatuPDF',
      description:
          'Edita PDFs en el navegador: añade texto, firma, imágenes y anotaciones. '
          '100% gratis, privado y sin instalar programas.',
      keywords:
          'editar pdf, editar pdf online, firmar pdf, anotar pdf, añadir texto a pdf, '
          'editor pdf gratis, modificar pdf, $_baseKeywords',
      path: AppRoutes.edit,
    ),
    AppRoutes.contact: const SeoMeta(
      title: 'Contacto — MatuPDF | MatuByte',
      description:
          'Contacta al equipo de MatuPDF. Soporte, sugerencias y consultas sobre nuestras herramientas PDF.',
      keywords: 'contacto matupdf, soporte matupdf, matubyte, $_baseKeywords',
      path: AppRoutes.contact,
    ),
    AppRoutes.privacy: const SeoMeta(
      title: 'Política de privacidad — MatuPDF',
      description:
          'Cómo MatuPDF protege tus archivos. Procesamiento local en tu dispositivo, sin almacenamiento en servidores.',
      keywords: 'privacidad matupdf, seguridad pdf, $_baseKeywords',
      path: AppRoutes.privacy,
      robots: 'index, follow',
    ),
    AppRoutes.terms: const SeoMeta(
      title: 'Términos de servicio — MatuPDF',
      description: 'Términos de uso de MatuPDF, herramienta gratuita de MatuByte S.A.S.',
      keywords: 'terminos matupdf, uso matupdf, $_baseKeywords',
      path: AppRoutes.terms,
      robots: 'index, follow',
    ),
    AppRoutes.account: const SeoMeta(
      title: 'Mi cuenta — MatuPDF',
      description: 'Accede o crea tu cuenta en MatuPDF para guardar preferencias y sincronizar.',
      keywords: 'cuenta matupdf, login matupdf, $_baseKeywords',
      path: AppRoutes.account,
      robots: 'noindex, follow',
    ),
  };

  static SeoMeta forPath(String path) {
    final normalized = path.isEmpty ? AppRoutes.home : path.split('?').first;
    return byPath[normalized] ?? byPath[AppRoutes.home]!;
  }
}
