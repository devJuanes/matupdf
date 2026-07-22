/// Fragmento de texto extraído del PDF (coordenadas normalizadas 0–1).
class PdfTextItem {
  const PdfTextItem({
    required this.id,
    required this.pageIndex,
    required this.text,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  final String id;
  final int pageIndex;
  final String text;
  final double x;
  final double y;
  final double width;
  final double height;
  final double fontSize;
}
