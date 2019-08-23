import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aliyun_oss/utils.dart';
import 'package:http/http.dart' as http;

import 'exception.dart';

abstract class OSSConnection {
  OSSConnection._();

  static final OSSConnection http = HttpConnection();

  void checkResponse(int statusCode, String body) {
    switch (statusCode) {
      case HttpStatus.ok:
      case HttpStatus.noContent:
        return;
      default:
        break;
    }

    Map<String, Object> responseError = parkerDecode(body)['Error'];
    // TODO ClientException
    throw ServiceException(statusCode, responseError['Code']);
  }

  Future<String> getString(
    String url, {
    Map<String, String> headers,
  });

  Future<Uint8List> getObject(
    String url, {
    Map<String, String> headers,
  });

  Future<Map> put(
    String url, {
    Uint8List data,
    ContentType contentType,
  });
}

class HttpConnection extends OSSConnection {
  HttpConnection(): super._();

  @override
  Future<String> getString(
    String url, {
    Map<String, String> headers,
  }) async {
    var response = await http.get(url, headers: headers);
    checkResponse(response.statusCode, response.body);
    return response.body;
  }

  @override
  Future<Uint8List> getObject(
    String url, {
    Map<String, String> headers,
  }) async {
    var response = await http.get(url, headers: headers);
    checkResponse(response.statusCode, response.body);
    return response.bodyBytes;
  }

  @override
  Future<Map> put(
    String url, {
    Uint8List data,
    ContentType contentType,
  }) async {
    var response = await http.put(
      url,
      headers: {
        if (contentType != null) HttpHeaders.contentTypeHeader: contentType.toString(),
      },
      body: data,
    );
    return jsonDecode(response.body);
  }
}