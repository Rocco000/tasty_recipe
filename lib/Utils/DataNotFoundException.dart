class DataNotFoundException implements Exception{
  final String message;
  final StackTrace stackTrace;

  DataNotFoundException(this.message, this.stackTrace);
}