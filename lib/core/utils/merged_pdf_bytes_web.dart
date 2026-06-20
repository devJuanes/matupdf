import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

Future<Uint8List?> readMergedPdfBytesImpl(String pathOrUrl) async {
  if (pathOrUrl.isEmpty) return null;

  try {
    final response = await window.fetch(pathOrUrl.toJS).toDart;
    if (!response.ok) return null;
    final blob = await response.blob().toDart;
    final buffer = await blob.arrayBuffer().toDart;
    return Uint8List.view(buffer.toDart);
  } catch (_) {
    return null;
  }
}
