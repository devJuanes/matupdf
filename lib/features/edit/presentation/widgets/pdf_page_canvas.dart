import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/pdf_annotation.dart';
import '../../data/models/pdf_text_item.dart';
import '../controllers/edit_controller.dart';

class PdfPageCanvas extends StatefulWidget {
  const PdfPageCanvas({
    super.key,
    required this.controller,
    required this.onRequestText,
    required this.onRequestSignature,
    required this.onRequestImage,
    required this.onEditExistingText,
  });

  final EditController controller;
  final Future<String?> Function() onRequestText;
  final Future<String?> Function() onRequestSignature;
  final Future<String?> Function() onRequestImage;
  final Future<String?> Function(PdfTextItem item, String currentText)
      onEditExistingText;

  @override
  State<PdfPageCanvas> createState() => _PdfPageCanvasState();
}

class _PdfPageCanvasState extends State<PdfPageCanvas> {
  Offset? _dragStart;
  String? _drawingId;
  List<Offset> _pencilPoints = [];

  EditController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final page = c.currentPage;
    final imageUrl = c.pageImage(page);
    final size = c.pageSize(page);
    final annotations = c.annotationsForPage(page);
    final textItems = c.textItemsForPage(page);
    final zoom = c.zoom;

    if (imageUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspect = size != null && size.height > 0
            ? size.width / size.height
            : 0.707;
        var baseW = constraints.maxWidth;
        var baseH = baseW / aspect;
        if (baseH > constraints.maxHeight && zoom <= 1) {
          baseH = constraints.maxHeight;
          baseW = baseH * aspect;
        }

        final w = baseW * zoom;
        final h = baseH * zoom;

        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          panEnabled: c.tool == EditTool.move || zoom > 1.05,
          scaleEnabled: true,
          onInteractionEnd: (_) {
            // Keep button zoom as source of truth when using +/-
          },
          child: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: AppColors.cardShadow(isDark: false),
                      ),
                      child: Image.network(imageUrl, fit: BoxFit.fill),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: c.tool == EditTool.editText
                          ? HitTestBehavior.translucent
                          : HitTestBehavior.opaque,
                      onTapDown: c.tool == EditTool.editText
                          ? null
                          : (d) => _onTap(d.localPosition, Size(w, h)),
                      onPanStart: c.tool == EditTool.editText
                          ? null
                          : (d) => _onPanStart(d.localPosition, Size(w, h)),
                      onPanUpdate: c.tool == EditTool.editText
                          ? null
                          : (d) => _onPanUpdate(d.localPosition, Size(w, h)),
                      onPanEnd: c.tool == EditTool.editText
                          ? null
                          : (_) => _onPanEnd(Size(w, h)),
                      child: Stack(
                        children: [
                          for (final a in annotations)
                            _AnnotationLayer(
                              annotation: a,
                              canvasSize: Size(w, h),
                              selected: a.id == c.selectedAnnotationId,
                              movable: c.tool == EditTool.move,
                              onSelect: () => c.selectAnnotation(a.id),
                              onMoved: (updated) =>
                                  c.updateAnnotation(updated),
                              onMoveStart: c.beginGestureUndo,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Encima de todo: editar texto existente es la prioridad.
                  if (c.tool == EditTool.editText)
                    ...textItems.map(
                      (item) => _TextHitBox(
                        item: item,
                        canvasSize: Size(w, h),
                        displayText: c.displayTextForItem(item),
                        onTap: () async {
                          final current = c.displayTextForItem(item);
                          final edited =
                              await widget.onEditExistingText(item, current);
                          if (edited == null) return;
                          c.replaceExistingText(item: item, newText: edited);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTap(Offset local, Size canvas) async {
    final nx = (local.dx / canvas.width).clamp(0.0, 1.0);
    final ny = (local.dy / canvas.height).clamp(0.0, 1.0);

    switch (c.tool) {
      case EditTool.addText:
        final text = await widget.onRequestText();
        if (text == null || text.trim().isEmpty) return;
        c.addAnnotation(
          PdfAnnotation(
            id: c.newId(),
            pageIndex: c.currentPage,
            type: AnnotationType.text,
            x: nx,
            y: ny,
            width: 0.35,
            height: 0.05,
            text: text.trim(),
            color: AppColors.primary,
            fontSize: 16,
          ),
        );
      case EditTool.sign:
        final dataUrl = await widget.onRequestSignature();
        if (dataUrl == null) return;
        c.addAnnotation(
          PdfAnnotation(
            id: c.newId(),
            pageIndex: c.currentPage,
            type: AnnotationType.signature,
            x: nx,
            y: ny,
            width: 0.28,
            height: 0.1,
            imageDataUrl: dataUrl,
          ),
        );
      case EditTool.image:
        final dataUrl = await widget.onRequestImage();
        if (dataUrl == null) return;
        c.addAnnotation(
          PdfAnnotation(
            id: c.newId(),
            pageIndex: c.currentPage,
            type: AnnotationType.image,
            x: nx,
            y: ny,
            width: 0.3,
            height: 0.2,
            imageDataUrl: dataUrl,
          ),
        );
      case EditTool.cross:
        c.addAnnotation(
          PdfAnnotation(
            id: c.newId(),
            pageIndex: c.currentPage,
            type: AnnotationType.stampCross,
            x: nx,
            y: ny,
            width: 0.06,
            height: 0.06,
            color: AppColors.primary,
          ),
        );
      case EditTool.check:
        c.addAnnotation(
          PdfAnnotation(
            id: c.newId(),
            pageIndex: c.currentPage,
            type: AnnotationType.stampCheck,
            x: nx,
            y: ny,
            width: 0.06,
            height: 0.06,
            color: AppColors.success,
          ),
        );
      case EditTool.eraser:
        _eraseAt(nx, ny);
      case EditTool.move:
        c.selectAnnotation(null);
      default:
        break;
    }
  }

  void _eraseAt(double nx, double ny) {
    final hits = c.annotationsForPage(c.currentPage).where((a) {
      return nx >= a.x &&
          nx <= a.x + a.width &&
          ny >= a.y &&
          ny <= a.y + a.height;
    }).toList();
    if (hits.isEmpty) return;
    c.selectAnnotation(hits.last.id);
    c.removeSelected();
  }

  void _onPanStart(Offset local, Size canvas) {
    final nx = (local.dx / canvas.width).clamp(0.0, 1.0);
    final ny = (local.dy / canvas.height).clamp(0.0, 1.0);

    if (c.tool == EditTool.highlight || c.tool == EditTool.ellipse) {
      _dragStart = local;
      final id = c.newId();
      _drawingId = id;
      c.addAnnotation(
        PdfAnnotation(
          id: id,
          pageIndex: c.currentPage,
          type: c.tool == EditTool.highlight
              ? AnnotationType.highlight
              : AnnotationType.ellipse,
          x: nx,
          y: ny,
          width: 0.01,
          height: 0.01,
          color: c.tool == EditTool.highlight
              ? const Color(0xFFFFEB3B)
              : AppColors.primary,
        ),
      );
    } else if (c.tool == EditTool.pencil) {
      _pencilPoints = [Offset(nx, ny)];
      final id = c.newId();
      _drawingId = id;
      c.addAnnotation(
        PdfAnnotation(
          id: id,
          pageIndex: c.currentPage,
          type: AnnotationType.pencil,
          x: nx,
          y: ny,
          width: 0.01,
          height: 0.01,
          points: [Offset(nx, ny)],
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }
  }

  void _onPanUpdate(Offset local, Size canvas) {
    if (_drawingId == null) return;
    final nx = (local.dx / canvas.width).clamp(0.0, 1.0);
    final ny = (local.dy / canvas.height).clamp(0.0, 1.0);
    final existing =
        c.annotations.where((a) => a.id == _drawingId).firstOrNull;
    if (existing == null) return;

    if (c.tool == EditTool.highlight || c.tool == EditTool.ellipse) {
      if (_dragStart == null) return;
      final x0 = (_dragStart!.dx / canvas.width).clamp(0.0, 1.0);
      final y0 = (_dragStart!.dy / canvas.height).clamp(0.0, 1.0);
      final left = x0 < nx ? x0 : nx;
      final top = y0 < ny ? y0 : ny;
      final w = (x0 - nx).abs().clamp(0.01, 1.0);
      final h = (y0 - ny).abs().clamp(0.01, 1.0);
      c.updateAnnotation(
        existing.copyWith(x: left, y: top, width: w, height: h),
      );
    } else if (c.tool == EditTool.pencil) {
      _pencilPoints = [..._pencilPoints, Offset(nx, ny)];
      final xs = _pencilPoints.map((p) => p.dx);
      final ys = _pencilPoints.map((p) => p.dy);
      final minX = xs.reduce((a, b) => a < b ? a : b);
      final minY = ys.reduce((a, b) => a < b ? a : b);
      final maxX = xs.reduce((a, b) => a > b ? a : b);
      final maxY = ys.reduce((a, b) => a > b ? a : b);
      c.updateAnnotation(
        existing.copyWith(
          x: minX,
          y: minY,
          width: (maxX - minX).clamp(0.01, 1.0),
          height: (maxY - minY).clamp(0.01, 1.0),
          points: List<Offset>.from(_pencilPoints),
        ),
      );
    }
  }

  void _onPanEnd(Size canvas) {
    _dragStart = null;
    _drawingId = null;
    _pencilPoints = [];
  }
}

class _TextHitBox extends StatefulWidget {
  const _TextHitBox({
    required this.item,
    required this.canvasSize,
    required this.displayText,
    required this.onTap,
  });

  final PdfTextItem item;
  final Size canvasSize;
  final String displayText;
  final VoidCallback onTap;

  @override
  State<_TextHitBox> createState() => _TextHitBoxState();
}

class _TextHitBoxState extends State<_TextHitBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final left = widget.item.x * widget.canvasSize.width;
    final top = widget.item.y * widget.canvasSize.height;
    final width = widget.item.width * widget.canvasSize.width;
    final height = widget.item.height * widget.canvasSize.height;

    return Positioned(
      left: left,
      top: top,
      width: width.clamp(8, widget.canvasSize.width),
      height: height.clamp(10, widget.canvasSize.height),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.primary.withValues(alpha: 0.06),
              border: Border.all(
                color: _hovered
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.35),
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              widget.displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: height.clamp(9, 22),
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnotationLayer extends StatelessWidget {
  const _AnnotationLayer({
    required this.annotation,
    required this.canvasSize,
    required this.selected,
    required this.movable,
    required this.onSelect,
    required this.onMoved,
    required this.onMoveStart,
  });

  final PdfAnnotation annotation;
  final Size canvasSize;
  final bool selected;
  final bool movable;
  final VoidCallback onSelect;
  final ValueChanged<PdfAnnotation> onMoved;
  final VoidCallback onMoveStart;

  @override
  Widget build(BuildContext context) {
    final left = annotation.x * canvasSize.width;
    final top = annotation.y * canvasSize.height;
    final width = annotation.width * canvasSize.width;
    final height = annotation.height * canvasSize.height;

    Widget child = switch (annotation.type) {
      AnnotationType.text => Text(
          annotation.text ?? '',
          style: TextStyle(
            color: annotation.color,
            fontSize: annotation.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      AnnotationType.replaceText => Container(
          color: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            annotation.text ?? '',
            style: TextStyle(
              color: annotation.color,
              fontSize: (height * 0.85).clamp(8, 36),
              height: 1.1,
            ),
          ),
        ),
      AnnotationType.highlight => Container(
          color: const Color(0xFFFFEB3B).withValues(alpha: 0.45),
        ),
      AnnotationType.ellipse => Container(
          decoration: BoxDecoration(
            border: Border.all(color: annotation.color, width: 2),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      AnnotationType.signature || AnnotationType.image =>
        annotation.imageDataUrl != null
            ? Image.network(annotation.imageDataUrl!, fit: BoxFit.contain)
            : const SizedBox.shrink(),
      AnnotationType.stampCross => Icon(
          Icons.close_rounded,
          color: annotation.color,
          size: height.clamp(16, 48),
        ),
      AnnotationType.stampCheck => Icon(
          Icons.check_rounded,
          color: annotation.color,
          size: height.clamp(16, 48),
        ),
      AnnotationType.pencil => CustomPaint(
          painter: _PencilPainter(annotation.points, annotation.color),
          size: Size(width, height),
        ),
    };

    child = Container(
      decoration: selected
          ? BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
            )
          : null,
      child: child,
    );

    if (!movable) {
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(onTap: onSelect, child: child),
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onSelect,
        onPanStart: (_) => onMoveStart(),
        onPanUpdate: (d) {
          final nx = ((left + d.delta.dx) / canvasSize.width).clamp(0.0, 1.0);
          final ny = ((top + d.delta.dy) / canvasSize.height).clamp(0.0, 1.0);
          onMoved(annotation.copyWith(x: nx, y: ny));
        },
        child: child,
      ),
    );
  }
}

class _PencilPainter extends CustomPainter {
  _PencilPainter(this.points, this.color);

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxX = points.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final maxY = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    final spanX = (maxX - minX).clamp(0.0001, 1.0);
    final spanY = (maxY - minY).clamp(0.0001, 1.0);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final lx = ((points[i].dx - minX) / spanX) * size.width;
      final ly = ((points[i].dy - minY) / spanY) * size.height;
      if (i == 0) {
        path.moveTo(lx, ly);
      } else {
        path.lineTo(lx, ly);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PencilPainter oldDelegate) => true;
}
