Future<String> applyEditsImpl({
  required String pdfPath,
  required List<Map<String, dynamic>> annotations,
}) async {
  throw UnsupportedError(
    'La edición avanzada de PDF está disponible en la versión web.',
  );
}

Future<({String dataUrl, double width, double height, int pageCount})>
    renderPageImpl(String pdfPath, int pageNumber, {double scale = 1.5}) async {
  throw UnsupportedError('Vista de página no disponible en esta plataforma.');
}

Future<List<Map<String, dynamic>>> extractPageTextImpl(
  String pdfPath,
  int pageNumber,
) async {
  return const [];
}
