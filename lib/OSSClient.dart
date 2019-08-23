import 'dart:io';
import 'dart:typed_data';

import 'package:aliyun_oss/common.dart';
import 'package:aliyun_oss/connection.dart';
import 'package:aliyun_oss/sign.dart';
import 'package:meta/meta.dart';

class OSSClient {
  String endpoint;
  CredentialProvider credentialProvider;

  OSSClient(this.endpoint, this.credentialProvider);

  @visibleForTesting
  Future<Credentials> getCredentials() => credentialProvider.getCredentials();

  // TODO Optional arguments
  Future<String> getBucket(String bucket, String prefix) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'GET',
      resourcePath: '/$bucket/',
    );

    var queryParams = {
      'prefix': prefix,
    };
    var queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    var queryAppendix = (queryString != null ? '?$queryString' : '');

    return await OSSConnection.http.getString(
      "http://$bucket.${Uri.parse(endpoint).authority}/$queryAppendix",
      headers: signedHeaders,
    );
  }

  Future<String> putObject({
    @required String bucket,
    @required String objectKey,
    @required Uint8List content,
    @required String contentType,
    OSSCallbackRequest callback,
  }) async {
    var originHeaders = {
      HttpHeaders.contentTypeHeader: contentType,
      ...(callback?.toHeaders() ?? {}),
    };

    var credentials = await getCredentials();
    var signer = Signer(credentials);
    var safeHeaders = signer.sign(
      httpMethod: 'PUT',
      resourcePath: '/$bucket/$objectKey',
      headers: originHeaders,
    );

    return await OSSConnection.http.putObject(
      'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey',
      data: content,
      headers: {
        ...originHeaders,
        ...safeHeaders,
      },
    );
  }

  Future<Uint8List> getObject(String bucket, String objectKey) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'GET',
      resourcePath: '/$bucket/$objectKey',
    );

    return await OSSConnection.http.getObject(
      'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey',
      headers: signedHeaders,
    );
  }

  Future<String> deleteObject(String bucket, String objectKey) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'DELETE',
      resourcePath: '/$bucket/$objectKey',
    );

    return OSSConnection.http.delete(
      'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey',
      headers: signedHeaders,
    );
  }
}