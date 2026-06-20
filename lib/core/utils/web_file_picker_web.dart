import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'picked_blob_file.dart';

Future<List<PickedBlobFile>?> pickPdfFilesImpl() async {
  final completer = Completer<List<PickedBlobFile>?>();
  var completed = false;

  final input = HTMLInputElement()
    ..type = 'file'
    ..multiple = true
    ..accept = '.pdf,application/pdf'
    ..style.display = 'none';

  void complete(List<PickedBlobFile>? files) {
    if (completed) return;
    completed = true;
    input.remove();
    completer.complete(files);
  }

  void onChange(Event event) {
    final fileList = input.files;
    if (fileList == null || fileList.length == 0) {
      complete(null);
      return;
    }

    final picked = <PickedBlobFile>[];
    for (var i = 0; i < fileList.length; i++) {
      final file = fileList.item(i);
      if (file == null) continue;

      final blobUrl = URL.createObjectURL(file);
      picked.add(
        PickedBlobFile(
          name: file.name,
          size: file.size,
          blobUrl: blobUrl,
        ),
      );
    }

    complete(picked.isEmpty ? null : picked);
  }

  void onCancel(Event event) {
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!completed) complete(null);
    });
  }

  input.addEventListener('change', onChange.toJS);
  input.addEventListener('cancel', onCancel.toJS);
  document.body?.appendChild(input);
  input.click();

  return completer.future;
}
