class ServiceException {
  final int statusCode;

  final String errorCode;

  ServiceException(this.statusCode, this.errorCode);
}