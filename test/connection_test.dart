import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aliyun_oss/connection.dart';
import 'package:flutter_test/flutter_test.dart';

final connection = OSSConnection.http;
final binaryData = utf8.encode('0123456789');

void main() {
  test('test getString', () async {
    var response = await connection.getString(
      'https://postman-echo.com/get',
      headers: headerTester.headers,
    );
    var responseContent = jsonDecode(response);

    headerTester.check(responseContent);
  });

  test('test getObject', () async {
    var responseData = await connection.getObject(
      'https://postman-echo.com/get',
      headers: headerTester.headers,
    );
    var response = utf8.decode(responseData);
    var responseContent = jsonDecode(response);

    headerTester.check(responseContent);
  });

  test('test putObject', () async {
    var response = await connection.putObject(
      'https://postman-echo.com/put',
      data: binaryData,
      contentType: ContentType.binary,
      headers: headerTester.headers,
    );
    var responseContent = jsonDecode(response);

    headerTester.check(responseContent);
    
    Map requestData = responseContent['data'];
    expect(requestData['type'], 'Buffer');
    expect(requestData['data'], binaryData);
  });
}

final headerTester = HeaderTester();

class HeaderTester {
  static final random = Random();

  final headers = {
    'x-oss-var1': '${random.nextInt(1024)}',
    'x-oss-var2': '${random.nextInt(1024)}',
    'x-oss-var3': '${random.nextInt(1024)}',
  };

  void check(Map<String, Object> responseContent) {
    Map requestHeaders = responseContent['headers'];
    for (final e in headers.entries)
      expect(requestHeaders[e.key], headers[e.key]);
  }
}