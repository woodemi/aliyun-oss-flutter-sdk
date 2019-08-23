import 'dart:convert';
import 'dart:math';

import 'package:aliyun_oss/connection.dart';
import 'package:flutter_test/flutter_test.dart';

final connection = OSSConnection.http;
final binaryData = utf8.encode('0123456789');

void main() {
  test('test getString', () async {
    var random = Random();
    var headers = {
      'x-oss-var1': '${random.nextInt(1024)}',
      'x-oss-var2': '${random.nextInt(1024)}',
      'x-oss-var3': '${random.nextInt(1024)}',
    };
    var response = await connection.getString('https://postman-echo.com/get', headers: headers);
    Map requestHeaders = jsonDecode(response)['headers'];
    for (final e in headers.entries)
      expect(requestHeaders[e.key], headers[e.key]);
  });
}