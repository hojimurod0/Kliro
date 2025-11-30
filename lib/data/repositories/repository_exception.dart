class RepositoryException implements Exception {
  RepositoryException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'RepositoryException($message)';
}

