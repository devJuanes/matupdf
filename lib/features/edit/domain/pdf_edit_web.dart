import 'dart:convert';
import 'dart:js_interop';

@JS('matupdfEditReady')
external bool _matupdfEditReady();

@JS('matupdfApplyEdits')
external JSPromise<JSString> _matupdfApplyEdits(
  JSString blobUrl,
  JSAny annotations,
);

@JS('matupdfPreviewReady')
external bool _matupdfPreviewReady();

@JS('matupdfRenderPage')
external JSPromise<_PageRenderJs> _matupdfRenderPage(
  JSString blobUrl,
  JSNumber pageNumber,
  JSNumber scale,
);

@JS('matupdfExtractPageText')
external JSPromise<_TextExtractJs> _matupdfExtractPageText(
  JSString blobUrl,
  JSNumber pageNumber,
);

extension type _PageRenderJs._(JSObject _) implements JSObject {
  external JSString get dataUrl;
  external JSNumber get width;
  external JSNumber get height;
  external JSNumber get pageCount;
}

extension type _TextExtractJs._(JSObject _) implements JSObject {
  external JSArray get items;
}

Future<String> applyEditsImpl({
  required String pdfPath,
  required List<Map<String, dynamic>> annotations,
}) async {
  await _waitReady(() => _matupdfEditReady(), 'No se pudo cargar el motor de edición.');
  final json = jsonEncode(annotations);
  final parsed = jsonParse(json.toJS);
  final result = await _matupdfApplyEdits(pdfPath.toJS, parsed).toDart;
  return result.toDart;
}

Future<({String dataUrl, double width, double height, int pageCount})>
    renderPageImpl(String pdfPath, int pageNumber, {double scale = 1.5}) async {
  await _waitReady(() => _matupdfPreviewReady(), 'No se pudo cargar la vista previa.');
  final result = await _matupdfRenderPage(
    pdfPath.toJS,
    pageNumber.toJS,
    scale.toJS,
  ).toDart;
  return (
    dataUrl: result.dataUrl.toDart,
    width: result.width.toDartDouble,
    height: result.height.toDartDouble,
    pageCount: result.pageCount.toDartInt,
  );
}

Future<List<Map<String, dynamic>>> extractPageTextImpl(
  String pdfPath,
  int pageNumber,
) async {
  await _waitReady(() => _matupdfPreviewReady(), 'No se pudo cargar PDF.js.');
  final result = await _matupdfExtractPageText(
    pdfPath.toJS,
    pageNumber.toJS,
  ).toDart;
  final raw = result.items.dartify();
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => e.map((k, v) => MapEntry('$k', v)))
      .cast<Map<String, dynamic>>()
      .toList();
}

Future<void> _waitReady(bool Function() ready, String message) async {
  for (var i = 0; i < 80; i++) {
    if (ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError(message);
}

@JS('JSON.parse')
external JSAny jsonParse(JSString text);
