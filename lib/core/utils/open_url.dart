import 'open_url_stub.dart'
    if (dart.library.html) 'open_url_web.dart';

void openExternalUrl(String url) => openExternalUrlImpl(url);
