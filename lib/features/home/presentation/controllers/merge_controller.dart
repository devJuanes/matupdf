import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../data/models/pdf_file_item.dart';
import '../../domain/pdf_merge_service.dart';
import '../../domain/pdf_preview_service.dart';
import '../../../../core/utils/file_path_helper.dart';
import '../../../../core/utils/web_file_picker.dart';

enum WorkspaceViewMode { files, pages }

class MergeController extends ChangeNotifier {
  MergeController({
    PdfMergeService? mergeService,
    PdfPreviewService? previewService,
  })  : _mergeService = mergeService ?? PdfMergeService(),
        _previewService = previewService ?? PdfPreviewService();

  final PdfMergeService _mergeService;
  final PdfPreviewService _previewService;

  final List<PdfFileItem> _files = [];
  bool _isMerging = false;
  bool _isProcessingFiles = false;
  double _mergeProgress = 0;
  int _processingTotal = 0;
  int _processingDone = 0;
  String? _processingLabel;
  String? _errorMessage;
  String? _mergedOutputPath;
  WorkspaceViewMode _viewMode = WorkspaceViewMode.files;
  int _colorCounter = 0;

  List<PdfFileItem> get files => List.unmodifiable(_files);
  bool get isMerging => _isMerging;
  bool get isProcessingFiles => _isProcessingFiles;
  double get mergeProgress => _mergeProgress;
  double get processingProgress =>
      _processingTotal == 0 ? 0 : _processingDone / _processingTotal;
  int get processingTotal => _processingTotal;
  int get processingDone => _processingDone;
  String? get processingLabel => _processingLabel;
  String? get errorMessage => _errorMessage;
  String? get mergedOutputPath => _mergedOutputPath;
  bool get canMerge => _files.length >= 2 && !_isMerging && !_isProcessingFiles;
  bool get hasFiles => _files.isNotEmpty;
  WorkspaceViewMode get viewMode => _viewMode;
  bool _openWorkspacePending = false;
  bool get openWorkspacePending => _openWorkspacePending;

  bool _mergeAfterAuthPending = false;
  bool get mergeAfterAuthPending => _mergeAfterAuthPending;

  void scheduleMergeAfterAuth() {
    _mergeAfterAuthPending = true;
    notifyListeners();
  }

  bool consumeMergeAfterAuthRequest() {
    if (!_mergeAfterAuthPending) return false;
    _mergeAfterAuthPending = false;
    return true;
  }

  bool consumeOpenWorkspaceRequest() {
    if (!_openWorkspacePending) return false;
    _openWorkspacePending = false;
    return true;
  }

  void setViewMode(WorkspaceViewMode mode) {
    if (mode == WorkspaceViewMode.pages) return;
    _viewMode = mode;
    notifyListeners();
  }

  Future<void> pickFiles({int? insertAt}) async {
    _clearError();

    if (kIsWeb) {
      final picked = await WebFilePicker.pickPdfFiles();
      if (picked == null || picked.isEmpty) return;
      await _processBlobFiles(picked, insertAt: insertAt);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    await _processPlatformFiles(result.files, insertAt: insertAt);
  }

  Future<void> _processBlobFiles(
    List<PickedBlobFile> picked, {
    int? insertAt,
  }) async {
    _beginProcessing(picked.length, 'Preparando archivos…');
    await _yieldToUi();

    var index = insertAt ?? _files.length;
    final wasEmpty = _files.isEmpty;

    try {
      for (final file in picked) {
        _processingLabel = file.name;
        notifyListeners();

        final pdfFile = PdfFileItem(
          id: _nextId(),
          name: file.name,
          size: file.size,
          path: file.blobUrl,
          colorIndex: _nextColorIndex(),
          isThumbnailLoading: true,
        );

        _files.insert(index.clamp(0, _files.length), pdfFile);
        index++;
        notifyListeners();

        await _loadPreview(pdfFile.id);
        _processingDone++;
        notifyListeners();
        await _yieldToUi();
      }

      if (wasEmpty && _files.isNotEmpty) _openWorkspacePending = true;
    } finally {
      _endProcessing();
    }
  }

  Future<void> _yieldToUi() async {
    await Future<void>.delayed(Duration.zero);
    await SchedulerBinding.instance.endOfFrame;
  }

  Future<void> addDroppedFiles(List<DropItem> items, {int? insertAt}) async {
    _clearError();

    final pdfs = items
        .where((item) => item.name.toLowerCase().endsWith('.pdf'))
        .toList();
    if (pdfs.isEmpty) return;

    _beginProcessing(pdfs.length, 'Preparando archivos…');
    await _yieldToUi();

    var index = insertAt ?? _files.length;
    final wasEmpty = _files.isEmpty;

    try {
      for (final item in pdfs) {
        _processingLabel = item.name;
        notifyListeners();

        final fileSize = await item.length();
        final file = PdfFileItem(
          id: _nextId(),
          name: item.name,
          size: fileSize,
          path: item.path,
          colorIndex: _nextColorIndex(),
          isThumbnailLoading: true,
        );

        _files.insert(index.clamp(0, _files.length), file);
        index++;
        notifyListeners();

        await _loadPreview(file.id);
        _processingDone++;
        notifyListeners();
        await _yieldToUi();
      }

      if (wasEmpty && _files.isNotEmpty) _openWorkspacePending = true;
    } finally {
      _endProcessing();
    }
  }

  Future<void> _processPlatformFiles(
    List<PlatformFile> platformFiles, {
    int? insertAt,
  }) async {
    _beginProcessing(platformFiles.length, 'Leyendo archivos…');
    await _yieldToUi();

    var index = insertAt ?? _files.length;

    try {
      for (final file in platformFiles) {
        _processingLabel = file.name;
        notifyListeners();

        await _addPlatformFile(file, insertAt: index);
        index++;
        _processingDone++;
        notifyListeners();
        await _yieldToUi();
      }
    } finally {
      _endProcessing();
    }
  }

  void _beginProcessing(int total, String label) {
    _isProcessingFiles = true;
    _processingTotal = total;
    _processingDone = 0;
    _processingLabel = label;
    notifyListeners();
  }

  void _endProcessing() {
    _isProcessingFiles = false;
    _processingTotal = 0;
    _processingDone = 0;
    _processingLabel = null;
    notifyListeners();
  }

  Future<void> _addPlatformFile(PlatformFile file, {int? insertAt}) async {
    final path = await _resolvePath(file);
    if (path == null) return;

    final pdfFile = PdfFileItem(
      id: _nextId(),
      name: file.name,
      size: file.size,
      path: path,
      colorIndex: _nextColorIndex(),
      isThumbnailLoading: true,
    );

    final index = insertAt ?? _files.length;
    final wasEmpty = _files.isEmpty;
    _files.insert(index.clamp(0, _files.length), pdfFile);
    if (wasEmpty) _openWorkspacePending = true;
    notifyListeners();

    await _loadPreview(pdfFile.id);
  }

  Future<void> _loadPreview(String fileId) async {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index == -1) return;

    final file = _files[index];
    try {
      final preview = await _previewService.generatePreview(file.path);
      final currentIndex = _files.indexWhere((f) => f.id == fileId);
      if (currentIndex == -1) return;

      _files[currentIndex] = _files[currentIndex].copyWith(
        thumbnailPath: preview.thumbnailPath,
        pageCount: preview.pageCount,
        isThumbnailLoading: false,
      );
    } catch (_) {
      final currentIndex = _files.indexWhere((f) => f.id == fileId);
      if (currentIndex == -1) return;
      _files[currentIndex] =
          _files[currentIndex].copyWith(isThumbnailLoading: false);
    }
    notifyListeners();
  }

  Future<String?> _resolvePath(PlatformFile file) async {
    return FilePathHelper.resolvePlatformFile(
      name: file.name,
      path: file.path,
      bytes: file.bytes,
    );
  }

  void removeFile(String id) {
    _files.removeWhere((f) => f.id == id);
    _clearError();
    notifyListeners();
  }

  void duplicateFile(String id) {
    final index = _files.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final original = _files[index];
    _files.insert(
      index + 1,
      original.copyWith(id: _nextId(), colorIndex: _nextColorIndex()),
    );
    notifyListeners();
  }

  void rotateFile(String id) {
    final index = _files.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final file = _files[index];
    _files[index] = file.copyWith(rotation: (file.rotation + 90) % 360);
    notifyListeners();
  }

  void rotateAll() {
    for (var i = 0; i < _files.length; i++) {
      final file = _files[i];
      _files[i] = file.copyWith(rotation: (file.rotation + 90) % 360);
    }
    notifyListeners();
  }

  void sortAlphabetically() {
    _files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    notifyListeners();
  }

  void reorderFiles(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _files.removeAt(oldIndex);
    _files.insert(newIndex, item);
    notifyListeners();
  }

  void moveFile(String id, int newIndex) {
    final oldIndex = _files.indexWhere((f) => f.id == id);
    if (oldIndex == -1) return;
    final item = _files.removeAt(oldIndex);
    _files.insert(newIndex.clamp(0, _files.length), item);
    notifyListeners();
  }

  void clearFiles() {
    _files.clear();
    _mergedOutputPath = null;
    _clearError();
    notifyListeners();
  }

  Future<void> mergePdfs() async {
    if (!canMerge) return;

    _isMerging = true;
    _mergeProgress = 0.05;
    _mergedOutputPath = null;
    _clearError();
    notifyListeners();

    try {
      for (var i = 0; i < _files.length; i++) {
        _mergeProgress = 0.1 + (0.5 * i / _files.length);
        notifyListeners();
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }

      _mergeProgress = 0.65;
      notifyListeners();

      final outputPath = await _mergeService.mergeFiles(_files);

      _mergeProgress = 0.85;
      notifyListeners();

      await _mergeService.saveMergedFile(outputPath);

      _mergedOutputPath = outputPath;
      _mergeProgress = 1;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isMerging = false;
      notifyListeners();
    }
  }

  void dismissMergeResult() {
    _mergedOutputPath = null;
    _mergeProgress = 0;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;

  String _nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_files.length}';

  int _nextColorIndex() {
    final index = _colorCounter;
    _colorCounter++;
    return index;
  }
}
