import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readMergedPdfBytesImpl(String pathOrUrl) async {
  final file = File(pathOrUrl);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}
