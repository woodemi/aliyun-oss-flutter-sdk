import 'dart:convert';
import 'dart:io';

import 'package:aliyun_oss/OSSClient.dart';
import 'package:aliyun_oss/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

var _ossClient = OSSClient(Platform.environment['OSS_ENDPOINT'], TestFederationCredentialProvider());

class TestFederationCredentialProvider extends FederationCredentialProvider {
  final String fetchCredentialsApi = Platform.environment['FETCH_CREDENTIALS_API'];
  final String accessToken = Platform.environment['ACCESS_TOKEN'];
  final String appId = Platform.environment['APP_ID'];

  @override
  Future<FederationCredentials> fetchFederationCredentials() async {
    var response = await http.post(
      fetchCredentialsApi,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.value
      },
      body: jsonEncode({
        'appId': appId,
        'accessToken': accessToken,
        'appTimestamp': DateTime.now().millisecondsSinceEpoch,
      })
    );

    var map = jsonDecode(response.body)['data']['auth'];
    return FederationCredentials.fromMap(map);
  }
}

void testOSSApi() {
  test('test getBucket', () async {
    var response = await _ossClient.getBucket(Platform.environment['TEST_BUCKET'], Platform.environment['TEST_PREFIX']);
    expect(response, isNotNull);
  });

  test('test getObject', () async {
    var responseData = await _ossClient.getObject(Platform.environment['TEST_BUCKET'], Platform.environment['TEST_OBJECT_KEY']);
    expect(responseData, isNotNull);
  });
}
