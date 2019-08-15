import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import 'common.dart';

class Signer {
  final Credentials credentials;

  Signer(this.credentials): assert(credentials != null);

  Map<String, Object> sign({
    @required String httpMethod,
    @required String resourcePath,
    Map<String, String> parameters,
    Map<String, Object> headers,
    String contentMd5,
  }) {
    assert(httpMethod != null);
    assert(resourcePath != null);

    var securityHeaders = {
      if (headers != null) ...headers,
      if (credentials.securityToken != null) 'x-oss-security-token': credentials.securityToken,
    };
    var sortedPairs = securityHeaders.entries
        .map((e) => MapEntry(e.key.toLowerCase().trim(), e.value.toString().trim()))
        .toList()..sort((a, b) => a.key.compareTo(b.key));
    var contentType = sortedPairs.firstWhere(
      (e) => e.key == HttpHeaders.contentTypeHeader,
      orElse: () => MapEntry('', ''),
    ).value;
    var canonicalizedOSSHeaders = sortedPairs
        .where((e) => e.key.startsWith('x-oss-'))
        .map((e) => '${e.key}:${e.value}')
        .join('\n');

    var canonicalizedResource = _buildCanonicalizedResource(resourcePath, parameters);

    var date = getDate();
    var canonicalString = [
      httpMethod,
      contentMd5 ?? '',
      contentType,
      date,
      if (canonicalizedOSSHeaders.isNotEmpty) canonicalizedOSSHeaders,
      canonicalizedResource,
    ].join('\n');

    var signature = _computeHmacSha1(canonicalString);
    return {
      'Date': date,
      'Authorization': 'OSS ${credentials.accessKeyId}:$signature',
      if (credentials.securityToken != null) 'x-oss-security-token': credentials.securityToken,
    };
  }

  @visibleForTesting
  String getDate() => HttpDate.format(DateTime.now());

  String _buildCanonicalizedResource(String resourcePath, Map<String, String> parameters) {
    // TODO Add parameters
    return resourcePath;
  }

  String _computeHmacSha1(String plaintext) {
    var digest = Hmac(sha1, utf8.encode(credentials.accessKeySecret)).convert(utf8.encode(plaintext));
    return base64.encode(digest.bytes);
  }
}