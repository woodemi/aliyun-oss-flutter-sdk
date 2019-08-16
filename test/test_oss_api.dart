import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'TestOSSClient.dart';

var _ossClient = TestOSSClient();

var bucket = Platform.environment['TEST_BUCKET'];
var prefix = Platform.environment['TEST_PREFIX'];
var objectKey = Platform.environment['TEST_OBJECT_KEY'];

void testOSSApi() {
  test('test getBucket', () async {
    var response = await _ossClient.getBucket(bucket, prefix);
    expect(response, isNotNull);
  });

  test('test putObject', () async {
    var response = await _ossClient.putObject(
      bucket: bucket,
      objectKey: objectKey,
      content: null, // FIXME
      contentType: ContentType.text.value,
    );
    expect(response, isNotNull);
  });

  test('test getObject', () async {
    var responseData = await _ossClient.getObject(bucket, objectKey);
    expect(responseData, isNotNull);
  });

  test('test deleteObject', () async {
    var responseData = await _ossClient.deleteObject(bucket, objectKey);
    expect(responseData, isNotNull);
  });
}
