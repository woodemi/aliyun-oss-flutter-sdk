import 'dart:convert';
import 'dart:math';

import 'package:aliyun_oss/connection.dart';
import 'package:flutter_test/flutter_test.dart';

final connection = OSSConnection.http;
final binaryData = utf8.encode('0123456789');

void main() {
  test('test getString', () async {
    var headers = _buildCustomHeaders();
    var response = await connection.getString('https://postman-echo.com/get', headers: headers);
    Map requestHeaders = jsonDecode(response)['headers'];
    for (final e in headers.entries)
      expect(requestHeaders[e.key], headers[e.key]);
  });

  test('test getObject', () async {
    var headers = _buildCustomHeaders();
    var responseData = await connection.getObject('https://postman-echo.com/get', headers: headers);
    var response = utf8.decode(responseData);
    Map requestHeaders = jsonDecode(response)['headers'];
    for (final e in headers.entries)
      expect(requestHeaders[e.key], headers[e.key]);
  });

  test('test put', () async {
    var response = await connection.put('https://postman-echo.com/put', data: binaryData, contentType: ContentType.binary);
    Map requestData = response['data'];
    expect(requestData['type'], 'Buffer');
    expect(requestData['data'], binaryData);
  });
}

Map<String, String> _buildCustomHeaders() {
  var random = Random();
  return {
    'x-oss-var1': '${random.nextInt(1024)}',
    'x-oss-var2': '${random.nextInt(1024)}',
    'x-oss-var3': '${random.nextInt(1024)}',
  };
}