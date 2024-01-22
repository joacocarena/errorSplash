class WrongCredentials implements Exception {}
class InvalidToken implements Exception {}
class ConnectionTimeout implements Exception {}
class CustomError {
  final String message;

  CustomError(this.message);
}