import 'dart:convert';
import 'dart:io';

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
    var response = await _ossClient.putObject(
      bucket: bucket,
      objectKey: objectKey,
      content: objectContent,
      contentType: ContentType.text.value,
    );
    expect(response, isNotNull);
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
