import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'common.dart';
import 'connection.dart';
import 'sign.dart';
import 'utils.dart';

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
    ).toHeaders();

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

  Future<String> signUrl(
    String bucket,
    String objectKey, {
    @required String httpMethod,
    int expireSeconds = 3600,
    String process,
  }) async {
    assert(httpMethod == 'PUT' || httpMethod == 'GET');
    var originParams = {
      if (process != null) 'x-oss-process': process,
    };

    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    var safeParams = signer.sign(
      httpMethod: httpMethod,
      resourcePath: '/$bucket/$objectKey',
      parameters: originParams,
      dateString: '${secondsSinceEpoch + expireSeconds}',
      signType: SignType.signUrl,
    ).toQueryParams();

    var queryParams = {
      ...safeParams,
      ...originParams,
    };
    return appendQueryParams('http://$bucket.${Uri.parse(endpoint).authority}/$objectKey', queryParams);
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
    ).toHeaders();

    return await OSSConnection.http.putObject(
      'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey',
      data: content,
      headers: {
        ...originHeaders,
        ...safeHeaders,
      },
    );
  }

  Future<Uint8List> getObject(
    String bucket,
    String objectKey, {
    String process,
  }) async {
    var credentials = await getCredentials();

    var queryParameters = {
      if (process != null) 'x-oss-process': process,
    };
    var signedHeaders = Signer(credentials).sign(
      httpMethod: 'GET',
      resourcePath: '/$bucket/$objectKey',
      parameters: queryParameters
    ).toHeaders();

    var path = 'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey';
    return await OSSConnection.http.getObject(
      appendQueryParams(path, queryParameters),
      headers: signedHeaders,
    );
  }

  Future<String> deleteObject(String bucket, String objectKey) async {
    var credentials = await getCredentials();

    var signer = Signer(credentials);
    var signedHeaders = signer.sign(
      httpMethod: 'DELETE',
      resourcePath: '/$bucket/$objectKey',
    ).toHeaders();

    return OSSConnection.http.delete(
      'http://$bucket.${Uri.parse(endpoint).authority}/$objectKey',
      headers: signedHeaders,
    );
  }
}