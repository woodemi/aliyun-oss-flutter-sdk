import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'exception.dart';
import 'utils.dart';

abstract class OSSConnection {
  OSSConnection._();

  static final OSSConnection http = HttpConnection();

  /// Check [statusCode] is 2XX of [HttpStatus]
  /// Or parse body string for error message
  ///
  /// Use function [getBodyString] for lazy parsing
  void checkResponse(int statusCode, String getBodyString()) {
    switch (statusCode) {
      case 200:
      case 204:
        return;
      default:
        break;
    }

    var body = getBodyString();
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

  Future<String> putObject(
    String url, {
    Uint8List data,
    Map<String, String> headers,
  });

  Future<String> delete(
    String url, {
    Map<String, String> headers,
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
    checkResponse(response.statusCode, () => bodyUtf8(response));
    return bodyUtf8(response);
  }

  @override
  Future<Uint8List> getObject(
    String url, {
    Map<String, String> headers,
  }) async {
    var response = await http.get(url, headers: headers);
    checkResponse(response.statusCode, () => bodyUtf8(response));
    return response.bodyBytes;
  }

  @override
  Future<String> putObject(
    String url, {
    Uint8List data,
    Map<String, String> headers,
  }) async {
    var response = await http.put(
      url,
      headers: headers,
      body: data,
    );
    checkResponse(response.statusCode, () => bodyUtf8(response));
    return bodyUtf8(response);
  }

  @override
  Future<String> delete(
    String url, {
    Map<String, String> headers,
  }) async {
    var response = await http.delete(url, headers: headers);
    checkResponse(response.statusCode, () => bodyUtf8(response));
    return bodyUtf8(response);
  }

  /// Decode [http.Response] with [utf8]
  ///
  /// [http.Response] default to [latin1] when charset missing in [ContentType]
  /// In which case chars in [utf8] may cause error
  String bodyUtf8(http.Response response) => utf8.decode(response.bodyBytes);
}