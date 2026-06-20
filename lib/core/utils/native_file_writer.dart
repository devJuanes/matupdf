import 'dart:typed_data';

import 'native_file_writer_stub.dart'
    if (dart.library.io) 'native_file_writer_io.dart';

Future<void> writeBytesToFile(String path, Uint8List bytes) =>
    writeBytesToFileImpl(path, bytes);
