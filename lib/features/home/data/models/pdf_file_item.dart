import 'package:flutter/material.dart';

class PdfFileItem {
  const PdfFileItem({
    required this.id,
    required this.name,
    required this.size,
    required this.path,
    this.rotation = 0,
    this.thumbnailPath,
    this.isThumbnailLoading = false,
    this.pageCount = 1,
    this.colorIndex = 0,
  });

  final String id;
  final String name;
  final int size;
  final String path;
  final int rotation;
  final String? thumbnailPath;
  final bool isThumbnailLoading;
  final int pageCount;
  final int colorIndex;

  PdfFileItem copyWith({
    String? id,
    String? name,
    int? size,
    String? path,
    int? rotation,
    String? thumbnailPath,
    bool? isThumbnailLoading,
    int? pageCount,
    int? colorIndex,
  }) {
    return PdfFileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      path: path ?? this.path,
      rotation: rotation ?? this.rotation,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isThumbnailLoading: isThumbnailLoading ?? this.isThumbnailLoading,
      pageCount: pageCount ?? this.pageCount,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}

class PdfLabelColors {
  PdfLabelColors._();

  static const List<Color> pastels = [
    Color(0xFFE8EAF6),
    Color(0xFFFFF9C4),
    Color(0xFFE0F2F1),
    Color(0xFFFCE4EC),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
  ];

  static Color forIndex(int index) => pastels[index % pastels.length];
}
