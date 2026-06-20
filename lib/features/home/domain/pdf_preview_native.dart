import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/models/image_from_pdf_config.dart';
import 'package:pdf_combiner/models/image_scale.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:pdf_combiner/responses/pdf_combiner_status.dart';

Future<({String? thumbnailPath, int pageCount})> generatePreviewImpl(
  String pdfPath,
) async {
  final outputDir = kIsWeb
      ? 'preview'
      : '${(await getTemporaryDirectory()).path}/matupdf_previews';

  final response = await PdfCombiner.createImageFromPDF(
    inputPath: pdfPath,
    outputDirPath: outputDir,
    config: const ImageFromPdfConfig(
      createOneImage: true,
      rescale: ImageScale(width: 240, height: 340),
    ),
  );

  if (response.status != PdfCombinerStatus.success ||
      response.outputPaths.isEmpty) {
    return (thumbnailPath: null, pageCount: 1);
  }

  return (
    thumbnailPath: response.outputPaths.first,
    pageCount: 1,
  );
}
