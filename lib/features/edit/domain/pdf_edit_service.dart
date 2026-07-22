import 'pdf_edit_native.dart' if (dart.library.html) 'pdf_edit_web.dart';

class PdfEditService {
  Future<String> applyEdits({
    required String pdfPath,
    required List<Map<String, dynamic>> annotations,
  }) {
    return applyEditsImpl(pdfPath: pdfPath, annotations: annotations);
  }
}
