class DatabaseOperationException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const DatabaseOperationException(this.message, this.stackTrace);
}
