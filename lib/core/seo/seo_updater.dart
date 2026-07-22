import 'package:flutter/foundation.dart';

import 'seo_meta.dart';
import 'seo_updater_stub.dart' if (dart.library.js_interop) 'seo_updater_web.dart';

/// Actualiza title, meta y canonical en Flutter Web según la ruta.
class SeoUpdater {
  SeoUpdater._();

  static void applyForPath(String path) {
    if (!kIsWeb) return;
    updateSeoDocument(SeoCatalog.forPath(path));
  }
}
