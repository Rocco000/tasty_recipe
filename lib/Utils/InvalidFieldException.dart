class InvalidFieldException implements Exception {
  final String fieldName;
  final String message;

  InvalidFieldException(this.fieldName, this.message);

  @override
  String toString() => "InvalidFieldException: [$fieldName] - $message";
}
