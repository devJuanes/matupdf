import 'package:web/web.dart' as web;

import 'seo_meta.dart';

void updateSeoDocument(SeoMeta meta) {
  web.document.title = meta.title;

  _setMetaName('description', meta.description);
  _setMetaName('keywords', meta.keywords);
  _setMetaName('robots', meta.robots);

  _setMetaProperty('og:title', meta.title);
  _setMetaProperty('og:description', meta.description);
  _setMetaProperty('og:url', meta.canonical);

  _setMetaName('twitter:title', meta.title);
  _setMetaName('twitter:description', meta.description);

  _setCanonical(meta.canonical);
}

void _setMetaName(String name, String content) {
  final el = web.document.querySelector('meta[name="$name"]') as web.HTMLMetaElement?;
  if (el != null) {
    el.content = content;
    return;
  }
  final created = web.HTMLMetaElement();
  created.name = name;
  created.content = content;
  web.document.head?.append(created);
}

void _setMetaProperty(String property, String content) {
  final el =
      web.document.querySelector('meta[property="$property"]') as web.HTMLMetaElement?;
  if (el != null) {
    el.content = content;
    return;
  }
  final created = web.HTMLMetaElement();
  created.setAttribute('property', property);
  created.content = content;
  web.document.head?.append(created);
}

void _setCanonical(String href) {
  final el =
      web.document.querySelector('link[rel="canonical"]') as web.HTMLLinkElement?;
  if (el != null) {
    el.href = href;
    return;
  }
  final created = web.HTMLLinkElement();
  created.rel = 'canonical';
  created.href = href;
  web.document.head?.append(created);
}
