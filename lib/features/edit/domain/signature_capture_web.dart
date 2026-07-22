import 'dart:js_interop';

@JS('matupdfSignatureToPng')
external JSString _matupdfSignatureToPng(
  JSAny points,
  JSNumber width,
  JSNumber height,
);

String signaturePointsToPngDataUrl(
  List<Map<String, double?>> points, {
  double width = 420,
  double height = 160,
}) {
  final jsPoints = points
      .map((p) {
        if (p['x'] == null || p['y'] == null) return null;
        return {'x': p['x'], 'y': p['y']};
      })
      .toList();
  // Encode via JSON round-trip for JS interop simplicity
  return _signatureViaJson(jsPoints, width, height);
}

@JS('JSON.stringify')
external JSString _jsonStringify(JSAny value);

@JS('JSON.parse')
external JSAny _jsonParse(JSString text);

String _signatureViaJson(
  List<Map<String, double?>?> points,
  double width,
  double height,
) {
  final encoded = _jsonStringify(points.jsify()!);
  final parsed = _jsonParse(encoded);
  return _matupdfSignatureToPng(parsed, width.toJS, height.toJS).toDart;
}
