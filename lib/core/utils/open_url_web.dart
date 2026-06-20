import 'package:web/web.dart';

void openExternalUrlImpl(String url) {
  HTMLAnchorElement()
    ..href = url
    ..target = '_blank'
    ..click();
}
