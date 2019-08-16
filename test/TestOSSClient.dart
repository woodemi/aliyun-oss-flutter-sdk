import 'dart:convert';
import 'dart:io';

import 'package:aliyun_oss/OSSClient.dart';
import 'package:aliyun_oss/common.dart';
import 'package:http/http.dart' as http;

class TestOSSClient extends OSSClient {
  TestOSSClient() : super(Platform.environment['OSS_ENDPOINT'], TestFederationCredentialProvider());
}

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