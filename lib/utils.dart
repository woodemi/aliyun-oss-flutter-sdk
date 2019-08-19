import 'dart:convert';

import 'package:xml2json/xml2json.dart';

Map<String, Object> parkerDecode(String xmlString) {
  var xml2json = Xml2Json()..parse(xmlString);
  return jsonDecode(xml2json.toParker());
}