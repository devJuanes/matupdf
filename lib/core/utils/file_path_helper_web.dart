import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

Future<String> createBlobUrlFromBytes(Uint8List bytes, String mimeType) async {
  final blobParts = [bytes.toJS].toJS;
  final blob = Blob(
    blobParts,
    BlobPropertyBag(type: mimeType),
  );
  return URL.createObjectURL(blob);
}

Future<void> downloadFile({
  required String outputPath,
  required String fileName,
}) async {
  final anchor = HTMLAnchorElement()
    ..href = outputPath
    ..download = fileName
    ..style.display = 'none';
  document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
