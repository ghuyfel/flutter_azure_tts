import 'package:flutter_azure_tts/src/auth/auth_token.dart';
import 'package:flutter_azure_tts/src/common/retry_policy.dart';

/// Improved configuration class with validation and immutability
class AzureTtsConfig {
  const AzureTtsConfig._({
    required this.subscriptionKey,
    required this.region,
    required this.withLogs,
    required this.retryPolicy,
    required this.requestTimeout,
  });

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

  final String subscriptionKey;
  final String region;
  final bool withLogs;
  final RetryPolicy retryPolicy;
  final Duration requestTimeout;

  static void _validateSubscriptionKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError('Subscription key cannot be empty');
    }
    if (key.length != 32) {
      throw ArgumentError('Invalid subscription key format');
    }
  }

  static void _validateRegion(String region) {
    if (region.isEmpty) {
      throw ArgumentError('Region cannot be empty');
    }
    // Add more region validation if needed
  }

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

/// Thread-safe singleton for configuration
class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();

  AzureTtsConfig? _config;
  AuthToken? _authToken;

  AzureTtsConfig get config {
    final config = _config;
    if (config == null) {
      throw StateError('AzureTtsConfig not initialized. Call FlutterAzureTts.init() first.');
    }
    return config;
  }

  void setConfig(AzureTtsConfig config) {
    _config = config;
  }

  AuthToken? get authToken => _authToken;
  
  void setAuthToken(AuthToken? token) {
    _authToken = token;
  }

  bool get isInitialized => _config != null;
}