import 'package:flutter/material.dart';

enum EditTool {
  thumbnails,
  move,
  undo,
  redo,
  addText,
  editText,
  sign,
  eraser,
  highlight,
  pencil,
  image,
  ellipse,
  annotations,
  links,
  cross,
  check,
  more,
  search,
  pageLayout,
}

enum AnnotationType {
  text,
  replaceText,
  highlight,
  signature,
  image,
  ellipse,
  pencil,
  stampCross,
  stampCheck,
}

/// Coordenadas normalizadas 0–1 relativas al tamaño de la página.
class PdfAnnotation {
  PdfAnnotation({
    required this.id,
    required this.pageIndex,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.text,
    this.color = const Color(0xFFE53935),
    this.fontSize = 16,
    this.imageDataUrl,
    this.strokeWidth = 2,
    this.points = const [],
  });

  final String id;
  final int pageIndex;
  final AnnotationType type;
  double x;
  double y;
  double width;
  double height;
  String? text;
  Color color;
  double fontSize;
  String? imageDataUrl;
  double strokeWidth;
  List<Offset> points;

  PdfAnnotation copyWith({
    String? id,
    int? pageIndex,
    AnnotationType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? text,
    Color? color,
    double? fontSize,
    String? imageDataUrl,
    double? strokeWidth,
    List<Offset>? points,
  }) {
    return PdfAnnotation(
      id: id ?? this.id,
      pageIndex: pageIndex ?? this.pageIndex,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      imageDataUrl: imageDataUrl ?? this.imageDataUrl,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      points: points ?? List<Offset>.from(this.points),
    );
  }

  Map<String, dynamic> toExportJson() {
    return {
      'id': id,
      'pageIndex': pageIndex,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'text': text,
      'color':
          '#${annotationColorHex(color)}',
      'fontSize': fontSize,
      'imageDataUrl': imageDataUrl,
      'strokeWidth': strokeWidth,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }
}

String annotationColorHex(Color color) {
  final value = color.toARGB32();
  return value.toRadixString(16).padLeft(8, '0').substring(2);
}

extension EditToolMeta on EditTool {
  String get label => switch (this) {
        EditTool.thumbnails => 'Miniaturas',
        EditTool.move => 'Mover',
        EditTool.undo => 'Deshacer',
        EditTool.redo => 'Rehacer',
        EditTool.addText => 'Añadir texto',
        EditTool.editText => 'Editar texto',
        EditTool.sign => 'Firmar',
        EditTool.eraser => 'Borrador',
        EditTool.highlight => 'Resaltador',
        EditTool.pencil => 'Lápiz',
        EditTool.image => 'Imagen',
        EditTool.ellipse => 'Elipse',
        EditTool.annotations => 'Anotaciones',
        EditTool.links => 'Enlaces',
        EditTool.cross => 'Cruz',
        EditTool.check => 'Visto',
        EditTool.more => 'Más',
        EditTool.search => 'Buscar',
        EditTool.pageLayout => 'Diseño',
      };

  IconData get icon => switch (this) {
        EditTool.thumbnails => Icons.grid_view_rounded,
        EditTool.move => Icons.near_me_outlined,
        EditTool.undo => Icons.undo_rounded,
        EditTool.redo => Icons.redo_rounded,
        EditTool.addText => Icons.title_rounded,
        EditTool.editText => Icons.text_fields_rounded,
        EditTool.sign => Icons.draw_rounded,
        EditTool.eraser => Icons.cleaning_services_outlined,
        EditTool.highlight => Icons.highlight_rounded,
        EditTool.pencil => Icons.edit_outlined,
        EditTool.image => Icons.image_outlined,
        EditTool.ellipse => Icons.circle_outlined,
        EditTool.annotations => Icons.chat_bubble_outline_rounded,
        EditTool.links => Icons.link_rounded,
        EditTool.cross => Icons.close_rounded,
        EditTool.check => Icons.check_rounded,
        EditTool.more => Icons.palette_outlined,
        EditTool.search => Icons.search_rounded,
        EditTool.pageLayout => Icons.description_outlined,
      };

  bool get isImplemented => switch (this) {
        EditTool.thumbnails ||
        EditTool.move ||
        EditTool.undo ||
        EditTool.redo ||
        EditTool.addText ||
        EditTool.editText ||
        EditTool.sign ||
        EditTool.highlight ||
        EditTool.pencil ||
        EditTool.image ||
        EditTool.ellipse ||
        EditTool.cross ||
        EditTool.check ||
        EditTool.eraser =>
          true,
        _ => false,
      };
}
