/// Base class for all Azure Text-to-Speech related exceptions.
/// 
/// This sealed class provides a comprehensive exception hierarchy for handling
/// different types of errors that can occur when using the Azure TTS service.
/// Each exception type represents a specific category of error, making it easier
/// to handle different scenarios appropriately.
/// 
/// ## Exception Hierarchy
/// 
/// - [InitializationException]: Configuration or setup errors
/// - [AuthenticationException]: Authentication and authorization errors
/// - [NetworkException]: Network connectivity and communication errors
/// - [ValidationException]: Input validation and parameter errors
/// - [RateLimitException]: API rate limiting errors
/// - [ServiceUnavailableException]: Azure service availability errors
/// 
/// ## Usage
/// 
/// ```dart
/// try {
///   await FlutterAzureTts.getTts(params);
/// } on ValidationException catch (e) {
///   print('Invalid input: ${e.message}');
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
///   if (e.cause != null) {
///     print('Caused by: ${e.cause}');
///   }
/// } on AzureTtsException catch (e) {
///   print('General Azure TTS error: ${e.message}');
/// }
/// ```
/// 
/// ## Error Context
/// 
/// All exceptions include:
/// - A descriptive error message
/// - Optional cause information for debugging
/// - Structured error handling through the type system
sealed class AzureTtsException implements Exception {
  /// Creates a new Azure TTS exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: A human-readable description of the error
  /// - [cause]: Optional underlying cause of the error (for debugging)
  const AzureTtsException(this.message, [this.cause]);
  
  /// Human-readable error message describing what went wrong.
  /// 
  /// This message is intended to be helpful for developers and may be
  /// suitable for logging or debugging purposes.
  final String message;
  
  /// Optional underlying cause of the error.
  /// 
  /// This can be another exception, error object, or any relevant context
  /// that might help with debugging the root cause of the problem.
  final Object? cause;

  @override
  String toString() => 'AzureTtsException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception thrown when there are problems with service initialization.
/// 
/// This exception is thrown when:
/// - Invalid configuration parameters are provided
/// - Required dependencies are missing
/// - The service fails to initialize properly
/// - Configuration validation fails
/// 
/// ## Common Causes
/// 
/// - Invalid subscription key format
/// - Empty or invalid region
/// - Network connectivity issues during initialization
/// - Missing required permissions
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   FlutterAzureTts.init(
///     subscriptionKey: 'invalid-key',
///     region: 'invalid-region',
///   );
/// } on InitializationException catch (e) {
///   print('Failed to initialize: ${e.message}');
///   // Handle initialization failure
/// }
/// ```
class InitializationException extends AzureTtsException {
  /// Creates a new initialization exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the initialization problem
  /// - [cause]: Optional underlying cause of the initialization failure
  const InitializationException(super.message, [super.cause]);
}

/// Exception thrown when authentication or authorization fails.
/// 
/// This exception is thrown when:
/// - The subscription key is invalid or expired
/// - The service region doesn't match the subscription
/// - Authentication tokens cannot be obtained or refreshed
/// - Access is denied due to insufficient permissions
/// 
/// ## Common Causes
/// 
/// - Incorrect subscription key
/// - Expired or suspended Azure subscription
/// - Wrong region configuration
/// - Network issues preventing token refresh
/// - Service quotas exceeded
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final voices = await FlutterAzureTts.getAvailableVoices();
/// } on AuthenticationException catch (e) {
///   print('Authentication failed: ${e.message}');
///   // Check subscription key and region
/// }
/// ```
class AuthenticationException extends AzureTtsException {
  /// Creates a new authentication exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the authentication problem
  /// - [cause]: Optional underlying cause of the authentication failure
  const AuthenticationException(super.message, [super.cause]);
}

/// Exception thrown when network communication fails.
/// 
/// This exception is thrown when:
/// - Network connectivity is unavailable
/// - HTTP requests timeout
/// - DNS resolution fails
/// - SSL/TLS handshake fails
/// - Server returns unexpected responses
/// 
/// ## Common Causes
/// 
/// - No internet connection
/// - Firewall blocking requests
/// - Azure service endpoints unreachable
/// - Request timeouts
/// - Proxy configuration issues
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final audio = await FlutterAzureTts.getTts(params);
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
///   // Retry with exponential backoff
/// }
/// ```
class NetworkException extends AzureTtsException {
  /// Creates a new network exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the network problem
  /// - [cause]: Optional underlying cause of the network failure
  const NetworkException(super.message, [super.cause]);
}

/// Exception thrown when input validation fails.
/// 
/// This exception is thrown when:
/// - Text is too long (exceeds 10,000 characters)
/// - Invalid audio format is specified
/// - Speech rate is outside valid range (0.5-3.0)
/// - Voice doesn't support requested style or role
/// - Required parameters are missing
/// 
/// ## Common Causes
/// 
/// - Text exceeding maximum length
/// - Invalid parameter combinations
/// - Unsupported voice features
/// - Missing required fields
/// - Invalid enum values
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final params = TtsParamsBuilder()
///       .text('Very long text...')  // Too long
///       .rate(5.0)  // Invalid rate
///       .build();
/// } on ValidationException catch (e) {
///   print('Validation error: ${e.message}');
///   // Fix the invalid parameters
/// }
/// ```
class ValidationException extends AzureTtsException {
  /// Creates a new validation exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the validation problem
  /// - [cause]: Optional underlying cause of the validation failure
  const ValidationException(super.message, [super.cause]);
}

/// Exception thrown when API rate limits are exceeded.
/// 
/// This exception is thrown when:
/// - Too many requests per second
/// - Too many requests per minute
/// - Monthly quota exceeded
/// - Concurrent request limits exceeded
/// 
/// ## Rate Limits
/// 
/// Azure TTS has several rate limits:
/// - 20 requests per second
/// - 200 requests per minute
/// - Monthly character limits based on subscription tier
/// 
/// ## Handling Rate Limits
/// 
/// When this exception is thrown, you should:
/// 1. Wait for the specified retry period
/// 2. Implement exponential backoff
/// 3. Consider request batching
/// 4. Monitor usage patterns
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final audio = await FlutterAzureTts.getTts(params);
/// } on RateLimitException catch (e) {
///   print('Rate limited: ${e.message}');
///   if (e.retryAfter != null) {
///     print('Retry after: ${e.retryAfter}');
///     await Future.delayed(e.retryAfter!);
///     // Retry the request
///   }
/// }
/// ```
class RateLimitException extends AzureTtsException {
  /// Creates a new rate limit exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the rate limiting
  /// - [cause]: Optional underlying cause
  const RateLimitException(super.message, [super.cause]);
  
  /// Duration to wait before retrying the request.
  /// 
  /// This value is typically provided by the Azure service in the
  /// 'Retry-After' header and indicates when the rate limit will reset.
  final Duration? retryAfter;
  
  /// Creates a rate limit exception with retry timing information.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the rate limiting
  /// - [retryAfter]: How long to wait before retrying
  /// - [cause]: Optional underlying cause
  const RateLimitException.withRetryAfter(
    String message, 
    this.retryAfter, 
    [Object? cause]
  ) : super(message, cause);
}

/// Exception thrown when Azure services are temporarily unavailable.
/// 
/// This exception is thrown when:
/// - Azure TTS service is down for maintenance
/// - Regional service outages occur
/// - Service capacity is temporarily exceeded
/// - Internal server errors occur
/// 
/// ## Common Causes
/// 
/// - Planned maintenance windows
/// - Unplanned service outages
/// - Regional capacity issues
/// - Azure infrastructure problems
/// 
/// ## Handling Service Unavailability
/// 
/// When this exception occurs:
/// 1. Implement retry logic with exponential backoff
/// 2. Consider fallback mechanisms
/// 3. Monitor Azure service health status
/// 4. Cache previous results when possible
/// 
/// ## Example
/// 
/// ```dart
/// try {
///   final voices = await FlutterAzureTts.getAvailableVoices();
/// } on ServiceUnavailableException catch (e) {
///   print('Service unavailable: ${e.message}');
///   // Use cached voices or show user-friendly error
/// }
/// ```
class ServiceUnavailableException extends AzureTtsException {
  /// Creates a new service unavailable exception.
  /// 
  /// ## Parameters
  /// 
  /// - [message]: Description of the service availability problem
  /// - [cause]: Optional underlying cause of the service issue
  const ServiceUnavailableException(super.message, [super.cause]);
}