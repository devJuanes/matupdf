import 'dart:io';

import 'dart:typed_data';

Future<String> createBlobUrlFromBytes(Uint8List bytes, String mimeType) async {
  throw UnsupportedError('Not supported on native platforms');
}

Future<void> downloadFile({
  required String outputPath,
  required String fileName,
}) async {
  final source = File(outputPath);
  if (!await source.exists()) return;

  final directory = source.parent;
  final target = File('${directory.path}/$fileName');
  if (target.path != source.path) {
    await source.copy(target.path);
  }
}
