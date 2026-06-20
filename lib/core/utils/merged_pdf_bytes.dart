import 'dart:typed_data';

import 'merged_pdf_bytes_stub.dart'
    if (dart.library.io) 'merged_pdf_bytes_io.dart'
    if (dart.library.html) 'merged_pdf_bytes_web.dart';

Future<Uint8List?> readMergedPdfBytes(String pathOrUrl) =>
    readMergedPdfBytesImpl(pathOrUrl);
