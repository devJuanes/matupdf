import 'dart:async';
import 'dart:js_interop';

@JS('matupdfPreviewReady')
external bool _matupdfPreviewReady();

@JS('matupdfGeneratePreview')
external JSPromise<PreviewResult> _matupdfGeneratePreview(JSString blobUrl);

extension type PreviewResult._(JSObject _) implements JSObject {
  external JSString get thumbnailUrl;
  external JSNumber get pageCount;
}

Future<({String? thumbnailPath, int pageCount})> generatePreviewImpl(
  String pdfPath,
) async {
  await _ensurePdfJsReady();

  final result = await _matupdfGeneratePreview(pdfPath.toJS).toDart;

  return (
    thumbnailPath: result.thumbnailUrl.toDart,
    pageCount: result.pageCount.toDartInt,
  );
}

Future<void> _ensurePdfJsReady() async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (_matupdfPreviewReady()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('No se pudo cargar el motor de vista previa PDF.');
}
