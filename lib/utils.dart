import 'dart:convert';

import 'package:xml2json/xml2json.dart';

String appendQueryParams(String url, Map<String, String> params) {
  var queryString = params.entries.map((e) => '${e.key}=${ossUrlEncode(e.value)}').join('&');
  return url + (queryString.isNotEmpty ? '?$queryString' : '');
}

/// [Uri.encodeComponent] `a b*c~d/e+f` to `a+b*c%7Ed%2Fe%2Bf`
/// Then transform `+` and `*`, then decode `~` and `/`
String ossUrlEncode(String s) => Uri.encodeComponent(s)
    .replaceAll('+', '%20').replaceAll('*', '%2A')
    .replaceAll('%7E', '~').replaceAll('%2F', '/');

Map<String, Object> parkerDecode(String xmlString) {
  var xml2json = Xml2Json()..parse(xmlString);
  return jsonDecode(xml2json.toParker());
}