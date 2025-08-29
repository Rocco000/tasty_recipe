class UnknownDatabaseException implements Exception {
  final String message;
  final StackTrace stackTrace;

  const UnknownDatabaseException(this.message, this.stackTrace);
}
