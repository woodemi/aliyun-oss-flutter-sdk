import 'dart:convert';
import 'dart:io';

import 'package:aliyun_oss/common.dart';
import 'package:aliyun_oss/connection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'TestOSSClient.dart';

var _ossClient = TestOSSClient();

var bucket = Platform.environment['TEST_BUCKET'];
var prefix = Platform.environment['TEST_PREFIX'];
var objectKey = Platform.environment['TEST_OBJECT_KEY'];
var content = utf8.encode('${DateTime.now().millisecondsSinceEpoch}');
var objectContent = utf8.encode('${DateTime.now().millisecondsSinceEpoch}');

void testOSSApi() {
  test('test getBucket', () async {
    var response = await _ossClient.getBucket(bucket, prefix);
    expect(response, isNotNull);
  });

  test('test putObject', () async {
    var customVars = {
      'var1': 'val1',
      'var2': '中文',
    };
    var callbackRequest = OSSCallbackRequest.build(
      'https://postman-echo.com/post',
      systemParams: {
        'filename': OSSCallbackRequest.VAR_OBJECT,
      },
      customVars: customVars,
    );

    var response = await _ossClient.putObject(
      bucket: bucket,
      objectKey: objectKey,
      content: objectContent,
      contentType: ContentType.text.toString(),
      callback: callbackRequest,
    );

    var responseForm = jsonDecode(response)['form'];
    expect(responseForm['filename'], objectKey);
    for (final p in customVars.keys)
      expect(responseForm[p], customVars[p]);
  });

  test('test signUrl get', () async {
    var url = await _ossClient.signUrl(bucket, objectKey, httpMethod: 'GET', expireSeconds: 60);
    var responseData = await OSSConnection.http.getObject(url);
    expect(responseData, objectContent);
  });

  test('test getObject', () async {
    var responseData = await _ossClient.getObject(bucket, objectKey);
    expect(responseData, objectContent);
  });

  test('test deleteObject', () async {
    var responseData = await _ossClient.deleteObject(bucket, objectKey);
    expect(responseData, isNotNull);
  });
}
