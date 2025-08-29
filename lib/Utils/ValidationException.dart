class ValidationException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const ValidationException(this.message, this.stackTrace);
}
