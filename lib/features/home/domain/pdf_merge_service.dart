import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:pdf_combiner/responses/pdf_combiner_status.dart';

import '../data/models/pdf_file_item.dart';
import '../../../core/utils/file_path_helper.dart';
import 'pdf_rotate_service.dart';

class PdfMergeService {
  PdfMergeService({PdfRotateService? rotateService})
      : _rotateService = rotateService ?? PdfRotateService();

  final PdfRotateService _rotateService;

  Future<String> mergeFiles(List<PdfFileItem> files) async {
    if (files.length < 2) {
      throw Exception('Se necesitan al menos 2 archivos PDF para combinar.');
    }

    final inputPaths = <String>[];
    for (final file in files) {
      inputPaths.add(await _prepareFilePath(file));
    }

    final outputPath = await _resolveOutputPath();

    final response = await PdfCombiner.mergeMultiplePDFs(
      inputPaths: inputPaths,
      outputPath: outputPath,
    );

    if (response.status != PdfCombinerStatus.success) {
      throw Exception(response.message);
    }

    return response.outputPath;
  }

  Future<String> _prepareFilePath(PdfFileItem file) async {
    if (file.rotation == 0) return file.path;
    return _rotateService.rotatePdf(file.path, file.rotation);
  }

  Future<String> _resolveOutputPath() async {
    if (kIsWeb) {
      return 'matupdf_merged.pdf';
    }

    final directory = await getTemporaryDirectory();
    return '${directory.path}/matupdf_merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  Future<void> saveMergedFile(String outputPath) async {
    await FilePathHelper.downloadMergedPdf(
      outputPath: outputPath,
      fileName: 'matupdf_merged.pdf',
    );
  }
}
