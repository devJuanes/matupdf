class AppConstants {
  AppConstants._();

  static const String appName = 'MatuPDF';
  static const String appTagline = 'Combina PDFs online gratis';
  static const String appDescription =
      'Herramienta 100% gratuita para combinar documentos PDF en el navegador. '
      'Sin registro, sin límites ocultos y con procesamiento local en tu dispositivo.';

  // SEO — actualiza la URL al desplegar en producción
  static const String siteUrl = 'https://matupdf.com';
  static const String seoTitle =
      'MatuPDF — Combinar PDFs online gratis | Sin registro';
  static const String seoDescription =
      'Une y combina archivos PDF gratis en segundos. Herramienta online sin registro, '
      'sin marcas de agua y 100% privada. Procesamiento local en tu navegador.';
  static const String seoKeywords =
      'combinar pdf, unir pdf, merge pdf, combinar pdf online gratis, '
      'unir pdf gratis, juntar pdf, combinar documentos pdf, pdf merger gratis';

  // MatuByte S.A.S. — empresa desarrolladora
  static const String companyName = 'MatuByte';
  static const String companyLegalName = 'MatuByte S.A.S.';
  static const String companyTagline = 'Soluciones digitales profesionales';
  static const String companyCountry = 'Colombia';
  static const String companyLocation = 'Cali, Colombia';
  static const String companyFounded = '2024';

  // Contacto
  static const String contactEmail = 'contacto@matubyte.com';
  static const String supportEmail = 'soporte@matubyte.com';
  static const String companyWebsite = 'https://matubyte.com';
  static const String companyPhone = '+57 333 277 1764';

  static const double maxContentWidth = 1280;
  static const double sectionPaddingDesktop = 80;
  static const double sectionPaddingTablet = 48;
  static const double sectionPaddingMobile = 24;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
}

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String merge = '/combinar';
  static const String account = '/cuenta';
  static const String contact = '/contacto';
  static const String privacy = '/privacidad';
  static const String terms = '/terminos';
}
