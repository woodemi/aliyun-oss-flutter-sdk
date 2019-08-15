class Credentials {
  final String accessKeyId;
  final String accessKeySecret;
  final String securityToken;

  Credentials(this.accessKeyId, this.accessKeySecret, [this.securityToken])
      : assert(accessKeyId != null),
        assert(accessKeySecret != null);
}
