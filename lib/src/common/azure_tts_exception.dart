/// Improved exception hierarchy with better error information
sealed class AzureTtsException implements Exception {
  const AzureTtsException(this.message, [this.cause]);
  
  final String message;
  final Object? cause;

  @override
  String toString() => 'AzureTtsException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

class InitializationException extends AzureTtsException {
  const InitializationException(super.message, [super.cause]);
}

class AuthenticationException extends AzureTtsException {
  const AuthenticationException(super.message, [super.cause]);
}

class NetworkException extends AzureTtsException {
  const NetworkException(super.message, [super.cause]);
}

class ValidationException extends AzureTtsException {
  const ValidationException(super.message, [super.cause]);
}

class RateLimitException extends AzureTtsException {
  const RateLimitException(super.message, [super.cause]);
  
  final Duration? retryAfter;
  
  const RateLimitException.withRetryAfter(
    String message, 
    this.retryAfter, 
    [Object? cause]
  ) : super(message, cause);
}

class ServiceUnavailableException extends AzureTtsException {
  const ServiceUnavailableException(super.message, [super.cause]);
}