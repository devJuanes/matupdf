import 'pdf_rotate_native.dart'
    if (dart.library.html) 'pdf_rotate_web.dart';

class PdfRotateService {
  Future<String> rotatePdf(String pdfPath, int rotationDegrees) {
    return rotatePdfImpl(pdfPath, rotationDegrees);
  }
}
