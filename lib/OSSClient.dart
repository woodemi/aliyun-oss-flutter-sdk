import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aliyun_oss/common.dart';
import 'package:aliyun_oss/sign.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
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

    var response = await http.get(
      "http://$bucket.${Uri.parse(endpoint).authority}/$queryAppendix",
      headers: signedHeaders,
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('HTTP Error'); // TODO
    }
    return response.body;
  }

  Future<String> putObject({
    @required String bucket,
    @required String objectKey,
    @required Uint8List content,
    @required String contentType,
    String encoding,
  }) async {
    var originHeaders = {
      HttpHeaders.contentTypeHeader: contentType,
    };

    var credentials = await getCredentials();
    var signer = Signer(credentials);
    var safeHeaders = signer.sign(
      httpMethod: 'PUT',
      resourcePath: '/$bucket/$objectKey',
      headers: originHeaders,
      contentMd5: content?.isNotEmpty == true ? base64.encode(md5.convert(content).bytes) : null,
    );

    var response = await http.put(
      "http://$bucket.${Uri.parse(endpoint).authority}/$objectKey",
      headers: {
        ...originHeaders,
        ...safeHeaders,
      },
      body: content,
      encoding: encoding != null ? Encoding.getByName(encoding) : null,
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('HTTP Error'); // TODO
    }
    return response.body;
  }

  Future<Uint8List> getObject(String bucket, String objectKey) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'GET',
      resourcePath: '/$bucket/$objectKey',
    );

    var response = await http.get(
      "http://$bucket.${Uri.parse(endpoint).authority}/$objectKey",
      headers: signedHeaders,
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('HTTP Error'); // TODO
    }
    return response.bodyBytes;
  }

  Future<String> deleteObject(String bucket, String objectKey) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'DELETE',
      resourcePath: '/$bucket/$objectKey',
    );

    var response = await http.delete(
      "http://$bucket.${Uri.parse(endpoint).authority}/$objectKey",
      headers: signedHeaders,
    );
    // FIXME Delete empty file fails
//    if (response.statusCode != HttpStatus.ok) {
//      throw Exception('HTTP Error'); // TODO
//    }
    return response.body;
  }
}