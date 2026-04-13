abstract interface class ApiException implements Exception {}

class ApiServerException implements ApiException {
  ApiServerException(this.exception, this.stackTrace);
  Object exception;
  StackTrace stackTrace;
}

class ApiTimeoutException implements ApiException {
  ApiTimeoutException(this.time);
  int time;
}
