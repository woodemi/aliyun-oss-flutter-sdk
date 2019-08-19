import 'dart:convert';

class Credentials {
  final String accessKeyId;
  final String accessKeySecret;
  final String securityToken;

  Credentials(this.accessKeyId, this.accessKeySecret, [this.securityToken])
      : assert(accessKeyId != null),
        assert(accessKeySecret != null);
}

abstract class CredentialProvider {
  Future<Credentials> getCredentials();
}

class FederationCredentials extends Credentials {
  DateTime expiration;

  FederationCredentials.fromMap(Map<String, dynamic> map)
      : expiration = DateTime.parse(map['expiration']),
        super(map['accessKeyId'], map['accessKeySecret'], map['securityToken']);
}

abstract class FederationCredentialProvider implements CredentialProvider {
  FederationCredentials _ossFederationToken;

  Future<Credentials> getCredentials() async {
    var expire = _ossFederationToken?.expiration?.millisecondsSinceEpoch ?? 0;
    if (expire - DateTime.now().millisecondsSinceEpoch > Duration(minutes: 5).inMilliseconds) {
      return _ossFederationToken;
    }
    _ossFederationToken = await fetchFederationCredentials();
    return _ossFederationToken;
  }

  Future<FederationCredentials> fetchFederationCredentials();
}

class OSSCallbackRequest {
  static const VAR_BUCKET = 'bucket';
  static const VAR_OBJECT = 'object';
  static const VAR_ETAG = 'etag';
  static const VAR_SIZE = 'size';
  static const VAR_MIMETYPE = 'mimeType';
  static const VAR_IMAGEINFO_HEIGHT = 'imageInfo.height';
  static const VAR_IMAGEINFO_WIDTH = 'imageInfo.width';
  static const VAR_IMAGEINFO_FORMAT = 'imageInfo.format';

  final String callbackUrl;

  final String callbackHost;

  final String callbackBody;

  final String callbackBodyType;

  final Map<String, String> callbackVars;

  OSSCallbackRequest({
    this.callbackUrl,
    this.callbackHost,
    this.callbackBody,
    this.callbackBodyType,
    this.callbackVars,
  });

  static final encoding = json.fuse(utf8.fuse(base64));

  Map<String, String> toHeaders() {
    var callbackParams = {
      if (callbackUrl != null) 'callbackUrl': callbackUrl,
      if (callbackHost != null) 'callbackHost': callbackHost,
      if (callbackBody != null) 'callbackBody': callbackBody,
      if (callbackBodyType != null) 'callbackBodyType': callbackBodyType,
    };
    return {
      if (callbackParams.isNotEmpty) 'x-oss-callback': encoding.encode(callbackParams),
      if (callbackVars != null) 'x-oss-callback-var': encoding.encode(callbackVars),
    };
  }
}
