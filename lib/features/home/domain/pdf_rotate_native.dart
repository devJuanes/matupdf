import 'dart:typed_data';

import 'package:file_magic_number/file_magic_number.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/models/image_from_pdf_config.dart';
import 'package:pdf_combiner/models/image_scale.dart';
import 'package:pdf_combiner/models/pdf_from_multiple_image_config.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:pdf_combiner/responses/pdf_combiner_status.dart';

import '../../../core/utils/file_path_helper.dart';
import '../../../core/utils/native_file_writer.dart';

Future<String> rotatePdfImpl(String pdfPath, int rotationDegrees) async {
  if (rotationDegrees == 0) return pdfPath;

  final outputDir = kIsWeb
      ? 'rotated'
      : '${(await getTemporaryDirectory()).path}/matupdf_rotated';

  final imagesResponse = await PdfCombiner.createImageFromPDF(
    inputPath: pdfPath,
    outputDirPath: outputDir,
    config: const ImageFromPdfConfig(
      createOneImage: false,
      rescale: ImageScale(width: 1200, height: 1600),
    ),
  );

  if (imagesResponse.status != PdfCombinerStatus.success ||
      imagesResponse.outputPaths.isEmpty) {
    throw Exception('No se pudo preparar el PDF rotado.');
  }

  final rotatedPaths = <String>[];
  for (var i = 0; i < imagesResponse.outputPaths.length; i++) {
    final imagePath = imagesResponse.outputPaths[i];
    final bytes = await FileMagicNumber.getBytesFromPathOrBlob(imagePath);
    final rotatedBytes = _rotateBytes(bytes, rotationDegrees);
    final savedPath = await _saveRotatedImage(rotatedBytes, pdfPath, i);
    if (savedPath.isNotEmpty) rotatedPaths.add(savedPath);
  }

  if (rotatedPaths.isEmpty) {
    throw Exception('No se pudieron rotar las páginas del PDF.');
  }

  final pdfOutput = kIsWeb
      ? 'rotated_${pdfPath.hashCode}.pdf'
      : '$outputDir/rotated_${pdfPath.hashCode}.pdf';

  final pdfResponse = await PdfCombiner.createPDFFromMultipleImages(
    inputPaths: rotatedPaths,
    outputPath: pdfOutput,
    config: const PdfFromMultipleImageConfig(
      rescale: ImageScale.original,
    ),
  );

  if (pdfResponse.status == PdfCombinerStatus.success) {
    return pdfResponse.outputPath;
  }

  throw Exception(pdfResponse.message);
}

Uint8List _rotateBytes(Uint8List bytes, int degrees) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  return Uint8List.fromList(
    img.encodePng(img.copyRotate(decoded, angle: degrees.toDouble())),
  );
}

Future<String> _saveRotatedImage(
  Uint8List bytes,
  String sourceId,
  int index,
) async {
  if (kIsWeb) {
    return await FilePathHelper.resolvePlatformFile(
          name: 'rotated_${sourceId.hashCode}_$index.png',
          bytes: bytes,
        ) ??
        '';
  }

  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/rotated_${sourceId.hashCode}_$index.png';
  await writeBytesToFile(path, bytes);
  return path;
}
