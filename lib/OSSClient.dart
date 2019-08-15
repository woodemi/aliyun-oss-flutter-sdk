import 'dart:typed_data';

import 'package:aliyun_oss/common.dart';
import 'package:aliyun_oss/sign.dart';
import 'package:http/http.dart' as http;

class OSSClient {
  String endpoint;
  CredentialProvider credentialProvider;

  OSSClient(this.endpoint, this.credentialProvider);

  Future<Uint8List> getObject(String bucket, String objectKey) async {
    var credentials = await credentialProvider.getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'GET',
      resourcePath: '/$bucket/$objectKey',
    );

    var response = await http.get(
      "http://$bucket.${Uri.parse(endpoint).authority}/$objectKey",
      headers: signedHeaders,
    );
    // TODO Handle exception
    return response.bodyBytes;
  }
}