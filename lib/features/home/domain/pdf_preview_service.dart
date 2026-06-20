import 'pdf_preview_native.dart'
    if (dart.library.html) 'pdf_preview_web.dart';

class PdfPreviewService {
  Future<({String? thumbnailPath, int pageCount})> generatePreview(
    String pdfPath,
  ) async {
    return generatePreviewImpl(pdfPath);
  }
}
