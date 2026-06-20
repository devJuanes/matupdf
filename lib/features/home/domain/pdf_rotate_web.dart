import 'dart:async';
import 'dart:js_interop';

@JS('matupdfRotationReady')
external bool _matupdfRotationReady();

@JS('matupdfRotatePdf')
external JSPromise<JSString> _matupdfRotatePdf(
  JSString blobUrl,
  JSNumber degrees,
);

Future<String> rotatePdfImpl(String pdfPath, int rotationDegrees) async {
  if (rotationDegrees == 0) return pdfPath;

  await _ensureRotationReady();

  final result = await _matupdfRotatePdf(
    pdfPath.toJS,
    rotationDegrees.toJS,
  ).toDart;

  return result.toDart;
}

Future<void> _ensureRotationReady() async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (_matupdfRotationReady()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('No se pudo cargar el motor de rotación PDF.');
}
