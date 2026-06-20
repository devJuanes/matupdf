import 'package:flutter/material.dart';

import 'thumbnail_image_io.dart'
    if (dart.library.html) 'thumbnail_image_web.dart';

class PdfThumbnailImage extends StatelessWidget {
  const PdfThumbnailImage({
    super.key,
    required this.path,
    this.rotation = 0,
    this.fit = BoxFit.contain,
  });

  final String? path;
  final int rotation;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (path == null || path!.isEmpty) {
      child = _placeholder(context);
    } else {
      child = buildThumbnailImage(path!, fit: fit);
    }

    if (rotation == 0) return child;

    return AnimatedRotation(
      turns: rotation / 360,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.picture_as_pdf_rounded,
          size: 48,
          color: Color(0xFFE53935),
        ),
      ),
    );
  }
}
