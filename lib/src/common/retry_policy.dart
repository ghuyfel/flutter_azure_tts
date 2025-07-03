import 'dart:math';

/// Configurable retry policy for handling transient failures in HTTP requests.
/// 
/// This class defines how the Azure TTS client should handle temporary failures
/// such as network timeouts, rate limiting, or service unavailability. It implements
/// exponential backoff with optional jitter to prevent thundering herd problems.
/// 
/// ## Retry Strategy
/// 
/// The retry policy uses exponential backoff, where each retry attempt waits
/// progressively longer:
/// 
/// - Attempt 1: baseDelay
/// - Attempt 2: baseDelay * backoffMultiplier
/// - Attempt 3: baseDelay * backoffMultiplier²
/// - And so on...
/// 
/// ## Jitter
/// 
/// When jitter is enabled, a random factor is applied to the delay to prevent
/// multiple clients from retrying simultaneously (thundering herd effect).
/// 
/// ## Example
/// 
/// ```dart
/// // Conservative retry policy
/// final conservativePolicy = RetryPolicy(
///   maxRetries: 2,
///   baseDelay: Duration(seconds: 1),
///   maxDelay: Duration(seconds: 10),
/// );
/// 
/// // Aggressive retry policy
/// final aggressivePolicy = RetryPolicy(
///   maxRetries: 5,
///   baseDelay: Duration(milliseconds: 100),
///   maxDelay: Duration(seconds: 30),
///   backoffMultiplier: 1.5,
///   jitter: true,
/// );
/// ```
class RetryPolicy {
  /// Creates a new retry policy with the specified parameters.
  /// 
  /// ## Parameters
  /// 
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [baseDelay]: Initial delay between retries (default: 500ms)
  /// - [maxDelay]: Maximum delay between retries (default: 30s)
  /// - [backoffMultiplier]: Multiplier for exponential backoff (default: 2.0)
  /// - [jitter]: Whether to add random jitter to delays (default: true)
  /// 
  /// ## Validation
  /// 
  /// - maxRetries must be >= 0
  /// - baseDelay must be positive
  /// - maxDelay must be >= baseDelay
  /// - backoffMultiplier must be >= 1.0
  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitter = true,
  }) : assert(maxRetries >= 0, 'maxRetries must be non-negative'),
       assert(backoffMultiplier >= 1.0, 'backoffMultiplier must be >= 1.0');

  /// Maximum number of retry attempts.
  /// 
  /// Set to 0 to disable retries entirely. The total number of attempts
  /// will be maxRetries + 1 (including the initial attempt).
  /// 
  /// ## Recommended Values
  /// 
  /// - 0: No retries (fail fast)
  /// - 1-3: Conservative (good for user-facing operations)
  /// - 4-6: Aggressive (good for background operations)
  /// - 7+: Very aggressive (use with caution)
  final int maxRetries;

  /// Base delay for the first retry attempt.
  /// 
  /// This is the minimum delay that will be used. Subsequent retries
  /// will use exponentially increasing delays based on this value.
  /// 
  /// ## Recommended Values
  /// 
  /// - 100-500ms: Fast retries for transient network issues
  /// - 500ms-2s: Standard retries for most scenarios
  /// - 2s+: Slow retries for rate-limited APIs
  final Duration baseDelay;

  /// Maximum delay between retry attempts.
  /// 
  /// This caps the exponential backoff to prevent extremely long delays.
  /// The actual delay will never exceed this value, regardless of the
  /// retry attempt number.
  /// 
  /// ## Recommended Values
  /// 
  /// - 10-30s: Standard maximum for user-facing operations
  /// - 1-5min: Background operations that can tolerate longer delays
  final Duration maxDelay;

  /// Multiplier for exponential backoff calculation.
  /// 
  /// Each retry attempt multiplies the previous delay by this factor.
  /// Higher values result in more aggressive backoff.
  /// 
  /// ## Recommended Values
  /// 
  /// - 1.5: Gentle backoff
  /// - 2.0: Standard exponential backoff
  /// - 3.0: Aggressive backoff
  final double backoffMultiplier;

  /// Whether to add random jitter to retry delays.
  /// 
  /// When enabled, the actual delay will be randomized between 50% and 100%
  /// of the calculated delay. This helps prevent thundering herd problems
  /// when multiple clients retry simultaneously.
  /// 
  /// ## Benefits of Jitter
  /// 
  /// - Reduces server load spikes during recovery
  /// - Improves overall system stability
  /// - Prevents synchronized retry storms
  /// 
  /// ## When to Disable
  /// 
  /// - Testing scenarios where predictable timing is needed
  /// - Single-client applications where coordination isn't a concern
  final bool jitter;

  /// Calculates the delay for a specific retry attempt.
  /// 
  /// This method implements the exponential backoff algorithm with optional
  /// jitter. The delay increases exponentially with each attempt until it
  /// reaches the maximum delay.
  /// 
  /// ## Parameters
  /// 
  /// - [attempt]: The retry attempt number (1-based). Use 0 for no delay.
  /// 
  /// ## Returns
  /// 
  /// The [Duration] to wait before the retry attempt. Returns [Duration.zero]
  /// for attempt 0 or negative values.
  /// 
  /// ## Algorithm
  /// 
  /// 1. Calculate base exponential delay: baseDelay * (backoffMultiplier ^ (attempt - 1))
  /// 2. Cap the delay at maxDelay
  /// 3. Apply jitter if enabled (randomize between 50% and 100% of calculated delay)
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final policy = RetryPolicy(
  ///   baseDelay: Duration(milliseconds: 500),
  ///   backoffMultiplier: 2.0,
  ///   maxDelay: Duration(seconds: 10),
  ///   jitter: true,
  /// );
  /// 
  /// print(policy.getDelay(1)); // ~250-500ms (with jitter)
  /// print(policy.getDelay(2)); // ~500-1000ms (with jitter)
  /// print(policy.getDelay(3)); // ~1000-2000ms (with jitter)
  /// print(policy.getDelay(4)); // ~2000-4000ms (with jitter)
  /// print(policy.getDelay(5)); // ~5000-10000ms (capped at maxDelay)
  /// ```
  Duration getDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;
    
    // Calculate exponential backoff delay
    var delay = baseDelay.inMilliseconds * pow(backoffMultiplier, attempt - 1);
    
    // Cap at maximum delay
    delay = delay.clamp(0, maxDelay.inMilliseconds).toDouble();
    
    // Apply jitter if enabled
    if (jitter) {
      final random = Random();
      // Randomize between 50% and 100% of the calculated delay
      delay = delay * (0.5 + random.nextDouble() * 0.5);
    }
    
    return Duration(milliseconds: delay.round());
  }

  /// Creates a copy of this retry policy with modified values.
  /// 
  /// This is useful for creating variations of a base policy for different
  /// types of operations or error conditions.
  /// 
  /// ## Parameters
  /// 
  /// All parameters are optional. If not provided, the current value is retained.
  /// 
  /// ## Returns
  /// 
  /// A new [RetryPolicy] instance with the specified changes.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final basePolicy = RetryPolicy();
  /// 
  /// // More aggressive policy for background operations
  /// final backgroundPolicy = basePolicy.copyWith(
  ///   maxRetries: 5,
  ///   maxDelay: Duration(minutes: 2),
  /// );
  /// 
  /// // Conservative policy for user-facing operations
  /// final userPolicy = basePolicy.copyWith(
  ///   maxRetries: 1,
  ///   maxDelay: Duration(seconds: 5),
  /// );
  /// ```
  RetryPolicy copyWith({
    int? maxRetries,
    Duration? baseDelay,
    Duration? maxDelay,
    double? backoffMultiplier,
    bool? jitter,
  }) {
    return RetryPolicy(
      maxRetries: maxRetries ?? this.maxRetries,
      baseDelay: baseDelay ?? this.baseDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      jitter: jitter ?? this.jitter,
    );
  }

  @override
  String toString() {
    return 'RetryPolicy('
        'maxRetries: $maxRetries, '
        'baseDelay: $baseDelay, '
        'maxDelay: $maxDelay, '
        'backoffMultiplier: $backoffMultiplier, '
        'jitter: $jitter'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RetryPolicy &&
        other.maxRetries == maxRetries &&
        other.baseDelay == baseDelay &&
        other.maxDelay == maxDelay &&
        other.backoffMultiplier == backoffMultiplier &&
        other.jitter == jitter;
  }

  @override
  int get hashCode {
    return Object.hash(
      maxRetries,
      baseDelay,
      maxDelay,
      backoffMultiplier,
      jitter,
    );
  }
}