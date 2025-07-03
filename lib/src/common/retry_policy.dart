import 'dart:math';

/// Configurable retry policy for HTTP requests
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = Duration(milliseconds: 500),
    this.maxDelay = Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitter = true,
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool jitter;

  Duration getDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;
    
    var delay = baseDelay.inMilliseconds * pow(backoffMultiplier, attempt - 1);
    delay = delay.clamp(0, maxDelay.inMilliseconds).toDouble();
    
    if (jitter) {
      final random = Random();
      delay = delay * (0.5 + random.nextDouble() * 0.5);
    }
    
    return Duration(milliseconds: delay.round());
  }
}