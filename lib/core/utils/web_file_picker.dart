import 'picked_blob_file.dart';
import 'web_file_picker_stub.dart'
    if (dart.library.html) 'web_file_picker_web.dart';

export 'picked_blob_file.dart';

class WebFilePicker {
  WebFilePicker._();

  static Future<List<PickedBlobFile>?> pickPdfFiles() => pickPdfFilesImpl();
}
