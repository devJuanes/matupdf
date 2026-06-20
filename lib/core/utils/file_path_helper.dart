import 'package:flutter/foundation.dart';

import 'file_path_helper_web.dart'
    if (dart.library.io) 'file_path_helper_io.dart';

class FilePathHelper {
  FilePathHelper._();

  static Future<String?> resolvePlatformFile({
    required String name,
    String? path,
    Uint8List? bytes,
  }) async {
    if (path != null && path.isNotEmpty) return path;
    if (kIsWeb && bytes != null) {
      return createBlobUrlFromBytes(bytes, 'application/pdf');
    }
    return null;
  }

  static Future<void> downloadMergedPdf({
    required String outputPath,
    required String fileName,
  }) async {
    await downloadFile(outputPath: outputPath, fileName: fileName);
  }
}
