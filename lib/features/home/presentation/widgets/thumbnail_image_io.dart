import 'dart:io';

import 'package:flutter/material.dart';

Widget buildThumbnailImage(String path, {BoxFit fit = BoxFit.contain}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
  );
}
