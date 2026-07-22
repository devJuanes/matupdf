import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/file_path_helper.dart';
import '../../../../core/utils/web_file_picker.dart';
import '../../../home/data/models/pdf_file_item.dart';
import '../../../home/domain/pdf_preview_service.dart';
import '../../data/models/pdf_annotation.dart';
import '../../data/models/pdf_text_item.dart';
import '../../domain/pdf_edit_native.dart'
    if (dart.library.html) '../../domain/pdf_edit_web.dart';
import '../../domain/pdf_edit_service.dart';

class EditController extends ChangeNotifier {
  EditController({
    PdfPreviewService? previewService,
    PdfEditService? editService,
  })  : _previewService = previewService ?? PdfPreviewService(),
        _editService = editService ?? PdfEditService();

  final PdfPreviewService _previewService;
  final PdfEditService _editService;
  final _uuid = const Uuid();

  PdfFileItem? _file;
  int _currentPage = 0;
  int _pageCount = 1;
  EditTool _tool = EditTool.editText;
  String? _selectedAnnotationId;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _showThumbnails = true;
  double _zoom = 1.0;

  final List<PdfAnnotation> _annotations = [];
  final List<List<Map<String, dynamic>>> _undoStack = [];
  final List<List<Map<String, dynamic>>> _redoStack = [];

  final Map<int, String> _pageImages = {};
  final Map<int, ({double width, double height})> _pageSizes = {};
  final Map<int, List<PdfTextItem>> _pageTexts = {};

  PdfFileItem? get file => _file;
  bool get hasFile => _file != null;
  int get currentPage => _currentPage;
  int get pageCount => _pageCount;
  EditTool get tool => _tool;
  String? get selectedAnnotationId => _selectedAnnotationId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  bool get showThumbnails => _showThumbnails;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  double get zoom => _zoom;

  List<PdfAnnotation> get annotations => List.unmodifiable(_annotations);

  List<PdfAnnotation> annotationsForPage(int page) =>
      _annotations.where((a) => a.pageIndex == page).toList();

  List<PdfTextItem> textItemsForPage(int page) =>
      List.unmodifiable(_pageTexts[page] ?? const []);

  String? pageImage(int page) => _pageImages[page];
  ({double width, double height})? pageSize(int page) => _pageSizes[page];

  void setZoom(double value) {
    _zoom = value.clamp(0.5, 3.0);
    notifyListeners();
  }

  void zoomIn() => setZoom(_zoom + 0.25);
  void zoomOut() => setZoom(_zoom - 0.25);
  void resetZoom() => setZoom(1);

  Future<void> pickPdf() async {
    _clearError();
    if (kIsWeb) {
      final picked = await WebFilePicker.pickPdfFiles();
      if (picked == null || picked.isEmpty) return;
      final first = picked.first;
      await _loadFile(
        PdfFileItem(
          id: _uuid.v4(),
          name: first.name,
          size: first.size,
          path: first.blobUrl,
        ),
      );
      return;
    }
    // Native: reuse file picker via merge-style if needed later
    _errorMessage = 'La edición de PDF está optimizada para web por ahora.';
    notifyListeners();
  }

  Future<void> loadFromPath({
    required String name,
    required String path,
    int size = 0,
  }) async {
    await _loadFile(
      PdfFileItem(id: _uuid.v4(), name: name, size: size, path: path),
    );
  }

  Future<void> _loadFile(PdfFileItem file) async {
    _isLoading = true;
    _annotations.clear();
    _undoStack.clear();
    _redoStack.clear();
    _pageImages.clear();
    _pageSizes.clear();
    _pageTexts.clear();
    _currentPage = 0;
    _zoom = 1;
    _tool = EditTool.editText;
    _file = file;
    notifyListeners();

    try {
      final preview = await _previewService.generatePreview(file.path);
      _pageCount = preview.pageCount;
      if (preview.thumbnailPath != null) {
        _pageImages[0] = preview.thumbnailPath!;
      }
      await ensurePageLoaded(0);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensurePageLoaded(int pageIndex) async {
    if (_file == null) return;
    final needsImage = !_pageImages.containsKey(pageIndex) ||
        !_pageSizes.containsKey(pageIndex);
    final needsText = !_pageTexts.containsKey(pageIndex);

    try {
      if (needsImage) {
        final rendered = await renderPageImpl(
          _file!.path,
          pageIndex + 1,
          scale: 1.6,
        );
        _pageImages[pageIndex] = rendered.dataUrl;
        _pageSizes[pageIndex] = (width: rendered.width, height: rendered.height);
        _pageCount = rendered.pageCount;
      }
      if (needsText) {
        final raw = await extractPageTextImpl(_file!.path, pageIndex + 1);
        _pageTexts[pageIndex] = raw.map((j) {
          return PdfTextItem(
            id: j['id'] as String? ?? _uuid.v4(),
            pageIndex: pageIndex,
            text: j['text'] as String? ?? '',
            x: (j['x'] as num?)?.toDouble() ?? 0,
            y: (j['y'] as num?)?.toDouble() ?? 0,
            width: (j['width'] as num?)?.toDouble() ?? 0.05,
            height: (j['height'] as num?)?.toDouble() ?? 0.02,
            fontSize: (j['fontSize'] as num?)?.toDouble() ?? 12,
          );
        }).toList();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('ensurePageLoaded: $e');
    }
  }

  void setTool(EditTool tool) {
    if (tool == EditTool.thumbnails) {
      _showThumbnails = !_showThumbnails;
      notifyListeners();
      return;
    }
    if (tool == EditTool.undo) {
      undo();
      return;
    }
    if (tool == EditTool.redo) {
      redo();
      return;
    }
    if (!tool.isImplemented) {
      _errorMessage = '${tool.label}: próximamente';
      notifyListeners();
      return;
    }
    _tool = tool;
    _errorMessage = null;
    notifyListeners();
  }

  void selectPage(int index) {
    if (index < 0 || index >= _pageCount) return;
    _currentPage = index;
    _selectedAnnotationId = null;
    notifyListeners();
    ensurePageLoaded(index);
  }

  void selectAnnotation(String? id) {
    _selectedAnnotationId = id;
    notifyListeners();
  }

  void _pushUndo() {
    _undoStack.add(_annotations.map((a) => a.toExportJson()).toList());
    if (_undoStack.length > 40) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_annotations.map((a) => a.toExportJson()).toList());
    final prev = _undoStack.removeLast();
    _restoreFromJson(prev);
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_annotations.map((a) => a.toExportJson()).toList());
    final next = _redoStack.removeLast();
    _restoreFromJson(next);
  }

  void _restoreFromJson(List<Map<String, dynamic>> rows) {
    _annotations
      ..clear()
      ..addAll(rows.map(_fromJson));
    _selectedAnnotationId = null;
    notifyListeners();
  }

  PdfAnnotation _fromJson(Map<String, dynamic> j) {
    final typeName = j['type'] as String? ?? 'text';
    final type = AnnotationType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => AnnotationType.text,
    );
    final colorHex = (j['color'] as String? ?? '#E53935').replaceAll('#', '');
    final colorVal = int.tryParse(colorHex, radix: 16) ?? 0xE53935;
    final points = <Offset>[];
    final rawPoints = j['points'];
    if (rawPoints is List) {
      for (final p in rawPoints) {
        if (p is Map) {
          points.add(Offset(
            (p['x'] as num?)?.toDouble() ?? 0,
            (p['y'] as num?)?.toDouble() ?? 0,
          ));
        }
      }
    }
    return PdfAnnotation(
      id: j['id'] as String? ?? _uuid.v4(),
      pageIndex: j['pageIndex'] as int? ?? 0,
      type: type,
      x: (j['x'] as num?)?.toDouble() ?? 0.1,
      y: (j['y'] as num?)?.toDouble() ?? 0.1,
      width: (j['width'] as num?)?.toDouble() ?? 0.2,
      height: (j['height'] as num?)?.toDouble() ?? 0.05,
      text: j['text'] as String?,
      color: Color(0xFF000000 | colorVal),
      fontSize: (j['fontSize'] as num?)?.toDouble() ?? 16,
      imageDataUrl: j['imageDataUrl'] as String?,
      strokeWidth: (j['strokeWidth'] as num?)?.toDouble() ?? 2,
      points: points,
    );
  }

  void addAnnotation(PdfAnnotation annotation) {
    _pushUndo();
    _annotations.add(annotation);
    _selectedAnnotationId = annotation.id;
    notifyListeners();
  }

  void updateAnnotation(PdfAnnotation annotation) {
    final i = _annotations.indexWhere((a) => a.id == annotation.id);
    if (i < 0) return;
    _annotations[i] = annotation;
    notifyListeners();
  }

  void commitAnnotationMove(PdfAnnotation annotation) {
    // Already updated in place; push undo snapshot of previous state was skipped
    // for live drag. Callers should pushUndo before drag starts.
    final i = _annotations.indexWhere((a) => a.id == annotation.id);
    if (i < 0) return;
    _annotations[i] = annotation;
    notifyListeners();
  }

  void beginGestureUndo() => _pushUndo();

  void removeSelected() {
    if (_selectedAnnotationId == null) return;
    _pushUndo();
    _annotations.removeWhere((a) => a.id == _selectedAnnotationId);
    _selectedAnnotationId = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String newId() => _uuid.v4();

  Future<void> exportPdf() async {
    if (_file == null) return;
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final outUrl = await _editService.applyEdits(
        pdfPath: _file!.path,
        annotations: _annotations.map((a) => a.toExportJson()).toList(),
      );
      await FilePathHelper.downloadMergedPdf(
        outputPath: outUrl,
        fileName: '${_file!.name.replaceAll('.pdf', '')}_editado.pdf',
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  void replaceExistingText({
    required PdfTextItem item,
    required String newText,
  }) {
    final existingIndex = _annotations.indexWhere(
      (a) =>
          a.type == AnnotationType.replaceText &&
          a.id == 'replace-${item.id}',
    );
    final annotation = PdfAnnotation(
      id: 'replace-${item.id}',
      pageIndex: item.pageIndex,
      type: AnnotationType.replaceText,
      x: item.x,
      y: item.y,
      width: item.width,
      height: item.height,
      text: newText,
      color: const Color(0xFF111827),
      fontSize: item.fontSize,
    );
    _pushUndo();
    if (existingIndex >= 0) {
      _annotations[existingIndex] = annotation;
    } else {
      _annotations.add(annotation);
    }
    _selectedAnnotationId = annotation.id;
    notifyListeners();
  }

  String displayTextForItem(PdfTextItem item) {
    for (final a in _annotations) {
      if (a.type == AnnotationType.replaceText && a.id == 'replace-${item.id}') {
        return a.text ?? item.text;
      }
    }
    return item.text;
  }

  void clear() {
    _file = null;
    _annotations.clear();
    _undoStack.clear();
    _redoStack.clear();
    _pageImages.clear();
    _pageSizes.clear();
    _pageTexts.clear();
    _currentPage = 0;
    _pageCount = 1;
    _zoom = 1;
    _selectedAnnotationId = null;
    notifyListeners();
  }
}
