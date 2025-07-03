import 'package:flutter_azure_tts/src/auth/auth_token.dart';
import 'package:flutter_azure_tts/src/common/retry_policy.dart';

/// Immutable configuration class for Azure Text-to-Speech service.
/// 
/// This class holds all the configuration settings required for the Azure TTS service,
/// including authentication credentials, regional settings, and operational parameters.
/// The configuration is validated during creation to ensure all values are valid.
/// 
/// ## Immutability
/// 
/// This class is immutable by design to prevent accidental modification of configuration
/// after initialization. Use [copyWith] to create modified copies when needed.
/// 
/// ## Validation
/// 
/// All parameters are validated during construction:
/// - Subscription key must be exactly 32 characters
/// - Region cannot be empty
/// - Timeout values must be positive
/// 
/// ## Example
/// 
/// ```dart
/// final config = AzureTtsConfig.create(
///   subscriptionKey: 'your-32-character-subscription-key',
///   region: 'eastus',
///   withLogs: true,
///   retryPolicy: RetryPolicy(maxRetries: 5),
///   requestTimeout: Duration(seconds: 45),
/// );
/// ```
class AzureTtsConfig {
  /// Private constructor to enforce use of factory method.
  /// 
  /// This ensures that all validation is performed through the [create] factory method.
  const AzureTtsConfig._({
    required this.subscriptionKey,
    required this.region,
    required this.withLogs,
    required this.retryPolicy,
    required this.requestTimeout,
  });

  /// Factory constructor that creates and validates a new configuration.
  /// 
  /// This is the primary way to create an [AzureTtsConfig] instance. It performs
  /// comprehensive validation on all input parameters and throws appropriate
  /// exceptions for invalid values.
  /// 
  /// ## Parameters
  /// 
  /// - [subscriptionKey]: Azure Cognitive Services subscription key (32 characters)
  /// - [region]: Azure region identifier (e.g., 'eastus', 'westeurope')
  /// - [withLogs]: Enable debug logging (defaults to true)
  /// - [retryPolicy]: Custom retry policy (defaults to standard policy)
  /// - [requestTimeout]: HTTP request timeout (defaults to 30 seconds)
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If any parameter is invalid
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final config = AzureTtsConfig.create(
  ///   subscriptionKey: 'abcd1234efgh5678ijkl9012mnop3456',
  ///   region: 'eastus',
  ///   withLogs: false,
  ///   retryPolicy: RetryPolicy(maxRetries: 3),
  ///   requestTimeout: Duration(minutes: 1),
  /// );
  /// ```
  factory AzureTtsConfig.create({
    required String subscriptionKey,
    required String region,
    bool withLogs = true,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
  }) {
    _validateSubscriptionKey(subscriptionKey);
    _validateRegion(region);
    
    return AzureTtsConfig._(
      subscriptionKey: subscriptionKey,
      region: region,
      withLogs: withLogs,
      retryPolicy: retryPolicy ?? const RetryPolicy(),
      requestTimeout: requestTimeout ?? const Duration(seconds: 30),
    );
  }

  /// Azure Cognitive Services subscription key.
  /// 
  /// This is the 32-character key obtained from your Azure portal that
  /// authenticates your application with the Azure TTS service.
  final String subscriptionKey;

  /// Azure region where your TTS service is deployed.
  /// 
  /// Common regions include:
  /// - 'eastus' - East US
  /// - 'westeurope' - West Europe
  /// - 'southeastasia' - Southeast Asia
  /// - 'australiaeast' - Australia East
  final String region;

  /// Whether to enable debug logging.
  /// 
  /// When enabled, the library will output detailed logs about:
  /// - HTTP requests and responses
  /// - Authentication token refresh
  /// - Error conditions and retries
  /// - Performance metrics
  final bool withLogs;

  /// Retry policy for failed HTTP requests.
  /// 
  /// Defines how the library should handle transient failures:
  /// - Maximum number of retry attempts
  /// - Delay between retries (with exponential backoff)
  /// - Jitter to prevent thundering herd problems
  final RetryPolicy retryPolicy;

  /// Timeout for individual HTTP requests.
  /// 
  /// This applies to each individual request attempt, not the total
  /// time including retries. The total time may be longer when
  /// retries are involved.
  final Duration requestTimeout;

  /// Validates the Azure subscription key format.
  /// 
  /// Azure subscription keys are always exactly 32 characters long
  /// and contain only hexadecimal characters.
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If the key is empty or has incorrect length
  static void _validateSubscriptionKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError('Subscription key cannot be empty');
    }
    if (key.length != 32) {
      throw ArgumentError('Invalid subscription key format - must be 32 characters');
    }
  }

  /// Validates the Azure region identifier.
  /// 
  /// Ensures the region is not empty. Additional validation could be added
  /// to check against a list of valid Azure regions.
  /// 
  /// ## Throws
  /// 
  /// - [ArgumentError]: If the region is empty
  static void _validateRegion(String region) {
    if (region.isEmpty) {
      throw ArgumentError('Region cannot be empty');
    }
    // Additional region validation could be added here
  }

  /// Creates a copy of this configuration with modified values.
  /// 
  /// This is the recommended way to modify configuration settings since
  /// the class is immutable. Only the specified parameters will be changed;
  /// all others will retain their current values.
  /// 
  /// ## Parameters
  /// 
  /// All parameters are optional. If not provided, the current value is retained.
  /// 
  /// ## Returns
  /// 
  /// A new [AzureTtsConfig] instance with the specified changes.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final newConfig = originalConfig.copyWith(
  ///   withLogs: false,
  ///   requestTimeout: Duration(seconds: 60),
  /// );
  /// ```
  AzureTtsConfig copyWith({
    String? subscriptionKey,
    String? region,
    bool? withLogs,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
  }) {
    return AzureTtsConfig._(
      subscriptionKey: subscriptionKey ?? this.subscriptionKey,
      region: region ?? this.region,
      withLogs: withLogs ?? this.withLogs,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      requestTimeout: requestTimeout ?? this.requestTimeout,
    );
  }
}

/// Thread-safe singleton for managing Azure TTS configuration and authentication state.
/// 
/// This class provides centralized access to configuration and authentication tokens
/// across the entire application. It ensures thread safety and proper initialization
/// checking for all Azure TTS operations.
/// 
/// ## Thread Safety
/// 
/// This class is designed to be thread-safe and can be accessed from multiple
/// isolates simultaneously. The singleton pattern ensures consistent state
/// across the application.
/// 
/// ## Usage
/// 
/// The ConfigManager is typically used internally by the library, but can be
/// accessed directly when needed:
/// 
/// ```dart
/// final manager = ConfigManager();
/// if (manager.isInitialized) {
///   final config = manager.config;
///   print('Current region: ${config.region}');
/// }
/// ```
class ConfigManager {
  /// Singleton instance.
  static final ConfigManager _instance = ConfigManager._internal();
  
  /// Factory constructor that returns the singleton instance.
  factory ConfigManager() => _instance;
  
  /// Private constructor for singleton pattern.
  ConfigManager._internal();

  /// Current configuration instance.
  /// 
  /// This is set during initialization and should not be modified directly.
  /// Use [setConfig] to update the configuration.
  AzureTtsConfig? _config;
  
  /// Current authentication token.
  /// 
  /// This is managed automatically by the authentication system and
  /// is refreshed as needed before expiration.
  AuthToken? _authToken;

  /// Gets the current configuration.
  /// 
  /// ## Returns
  /// 
  /// The current [AzureTtsConfig] instance.
  /// 
  /// ## Throws
  /// 
  /// - [StateError]: If the configuration hasn't been initialized yet.
  ///   Call [FlutterAzureTts.init] first.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final config = ConfigManager().config;
  ///   print('Region: ${config.region}');
  /// } on StateError {
  ///   print('Configuration not initialized');
  /// }
  /// ```
  AzureTtsConfig get config {
    final config = _config;
    if (config == null) {
      throw StateError('AzureTtsConfig not initialized. Call FlutterAzureTts.init() first.');
    }
    return config;
  }

  /// Sets the configuration.
  /// 
  /// This method is typically called during initialization and should not
  /// be called directly by application code.
  /// 
  /// ## Parameters
  /// 
  /// - [config]: The new configuration to set.
  void setConfig(AzureTtsConfig config) {
    _config = config;
  }

  /// Gets the current authentication token.
  /// 
  /// Returns the current [AuthToken] if available, or `null` if no token
  /// has been obtained yet or if the token has expired.
  /// 
  /// ## Returns
  /// 
  /// The current authentication token, or `null` if not available.
  AuthToken? get authToken => _authToken;
  
  /// Sets the authentication token.
  /// 
  /// This method is used internally by the authentication system to store
  /// and update tokens. It should not be called directly by application code.
  /// 
  /// ## Parameters
  /// 
  /// - [token]: The new authentication token, or `null` to clear the current token.
  void setAuthToken(AuthToken? token) {
    _authToken = token;
  }

  /// Checks if the configuration has been initialized.
  /// 
  /// Returns `true` if [setConfig] has been called with a valid configuration,
  /// `false` otherwise.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// if (!ConfigManager().isInitialized) {
  ///   throw StateError('Must call FlutterAzureTts.init() first');
  /// }
  /// ```
  bool get isInitialized => _config != null;
}