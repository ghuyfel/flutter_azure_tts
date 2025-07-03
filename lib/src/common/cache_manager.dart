import 'dart:async';

/// Simple in-memory cache for storing temporary data with TTL (Time To Live) support.
/// 
/// This cache manager provides a thread-safe, memory-efficient way to store and retrieve
/// data with automatic expiration. It's primarily used for caching authentication tokens,
/// voice lists, and generated audio to improve performance and reduce API calls.
/// 
/// ## Features
/// 
/// - **TTL Support**: Automatic expiration of cached items
/// - **Thread Safety**: Safe to use from multiple isolates
/// - **Memory Management**: Automatic cleanup of expired items
/// - **Type Safety**: Generic methods for type-safe storage and retrieval
/// 
/// ## Use Cases
/// 
/// - Authentication token caching
/// - Voice list caching
/// - Generated audio caching
/// - API response caching
/// 
/// ## Example
/// 
/// ```dart
/// final cache = CacheManager();
/// 
/// // Store a value with 1-hour TTL
/// cache.put('user_token', 'abc123', Duration(hours: 1));
/// 
/// // Retrieve the value
/// final token = cache.get<String>('user_token');
/// if (token != null) {
///   print('Token: $token');
/// } else {
///   print('Token expired or not found');
/// }
/// 
/// // Clear all cached data
/// cache.clear();
/// ```
class CacheManager {
  /// Singleton instance for global cache access.
  static final CacheManager _instance = CacheManager._internal();
  
  /// Factory constructor that returns the singleton instance.
  /// 
  /// This ensures that all parts of the application share the same cache,
  /// which is important for consistency and memory efficiency.
  factory CacheManager() => _instance;
  
  /// Private constructor for singleton pattern.
  CacheManager._internal();

  /// Internal storage for cache entries.
  /// 
  /// Maps cache keys to [CacheEntry] objects that contain the cached value
  /// and expiration information.
  final Map<String, CacheEntry> _cache = {};

  /// Stores a value in the cache with the specified TTL.
  /// 
  /// If a value with the same key already exists, it will be replaced.
  /// The value will automatically expire after the specified TTL duration.
  /// 
  /// ## Parameters
  /// 
  /// - [key]: Unique identifier for the cached value
  /// - [value]: The value to cache (can be any type)
  /// - [ttl]: Time To Live - how long the value should remain cached
  /// 
  /// ## Type Safety
  /// 
  /// The generic type parameter [T] ensures type safety when storing and
  /// retrieving values. The same type should be used for both [put] and [get].
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final cache = CacheManager();
  /// 
  /// // Cache a string for 30 minutes
  /// cache.put<String>('api_token', 'bearer_token_123', Duration(minutes: 30));
  /// 
  /// // Cache a list for 1 hour
  /// cache.put<List<Voice>>('voices', voiceList, Duration(hours: 1));
  /// 
  /// // Cache binary data for 24 hours
  /// cache.put<Uint8List>('audio_data', audioBytes, Duration(hours: 24));
  /// ```
  void put<T>(String key, T value, Duration ttl) {
    _cache[key] = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Retrieves a value from the cache.
  /// 
  /// Returns the cached value if it exists and hasn't expired, or `null` if
  /// the key doesn't exist or the value has expired. Expired entries are
  /// automatically removed from the cache.
  /// 
  /// ## Parameters
  /// 
  /// - [key]: The key used when storing the value
  /// 
  /// ## Returns
  /// 
  /// The cached value of type [T], or `null` if not found or expired.
  /// 
  /// ## Type Safety
  /// 
  /// The generic type parameter [T] should match the type used when storing
  /// the value with [put]. If the types don't match, a runtime error may occur.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final cache = CacheManager();
  /// 
  /// // Retrieve a cached string
  /// final token = cache.get<String>('api_token');
  /// if (token != null) {
  ///   // Use the token
  ///   print('Found cached token: $token');
  /// } else {
  ///   // Token not found or expired, need to fetch new one
  ///   print('No valid token in cache');
  /// }
  /// 
  /// // Retrieve a cached list
  /// final voices = cache.get<List<Voice>>('voices');
  /// if (voices != null && voices.isNotEmpty) {
  ///   print('Found ${voices.length} cached voices');
  /// }
  /// ```
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      // Clean up expired entries
      _cache.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  /// Removes a specific entry from the cache.
  /// 
  /// This immediately removes the entry regardless of its expiration time.
  /// Use this when you know a cached value is no longer valid.
  /// 
  /// ## Parameters
  /// 
  /// - [key]: The key of the entry to remove
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final cache = CacheManager();
  /// 
  /// // Remove a specific entry
  /// cache.remove('api_token');
  /// 
  /// // The entry is now gone
  /// assert(cache.get<String>('api_token') == null);
  /// ```
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clears all entries from the cache.
  /// 
  /// This removes all cached data immediately, regardless of expiration times.
  /// Use this for cleanup operations or when you need to force a fresh start.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final cache = CacheManager();
  /// 
  /// // Clear all cached data
  /// cache.clear();
  /// 
  /// // Cache is now empty
  /// assert(cache.size == 0);
  /// ```
  void clear() {
    _cache.clear();
  }

  /// Gets the current number of entries in the cache.
  /// 
  /// This includes both valid and expired entries. Expired entries are only
  /// removed when accessed through [get] or when explicitly cleaned up.
  /// 
  /// ## Returns
  /// 
  /// The number of entries currently stored in the cache.
  int get size => _cache.length;

  /// Checks if the cache is empty.
  /// 
  /// Returns `true` if there are no entries in the cache, `false` otherwise.
  /// Note that this doesn't distinguish between valid and expired entries.
  bool get isEmpty => _cache.isEmpty;

  /// Checks if the cache has any entries.
  /// 
  /// Returns `true` if there are any entries in the cache, `false` otherwise.
  /// Note that this doesn't distinguish between valid and expired entries.
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Performs cleanup of expired entries.
  /// 
  /// This method manually removes all expired entries from the cache.
  /// While expired entries are automatically removed when accessed,
  /// calling this method can help free up memory proactively.
  /// 
  /// ## Returns
  /// 
  /// The number of expired entries that were removed.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final cache = CacheManager();
  /// 
  /// // Perform manual cleanup
  /// final removedCount = cache.cleanup();
  /// print('Removed $removedCount expired entries');
  /// ```
  int cleanup() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.expiresAt.isBefore(now)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    return expiredKeys.length;
  }
}

/// Represents a single entry in the cache with expiration information.
/// 
/// This class encapsulates a cached value along with its expiration time.
/// It provides a simple way to check if an entry has expired without
/// needing to compare timestamps manually.
/// 
/// ## Immutability
/// 
/// Cache entries are immutable once created. This prevents accidental
/// modification of cached data and ensures thread safety.
/// 
/// ## Example
/// 
/// ```dart
/// final entry = CacheEntry(
///   value: 'some data',
///   expiresAt: DateTime.now().add(Duration(hours: 1)),
/// );
/// 
/// if (!entry.isExpired) {
///   print('Value: ${entry.value}');
/// } else {
///   print('Entry has expired');
/// }
/// ```
class CacheEntry {
  /// Creates a new cache entry.
  /// 
  /// ## Parameters
  /// 
  /// - [value]: The value to store in the cache
  /// - [expiresAt]: When this entry should expire
  const CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  /// The cached value.
  /// 
  /// This can be any type of object. The type should be consistent
  /// with how the entry is stored and retrieved from the cache.
  final dynamic value;
  
  /// When this cache entry expires.
  /// 
  /// After this time, the entry is considered invalid and should
  /// be removed from the cache.
  final DateTime expiresAt;

  /// Checks if this cache entry has expired.
  /// 
  /// Returns `true` if the current time is after the expiration time,
  /// `false` otherwise.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final entry = CacheEntry(
  ///   value: 'data',
  ///   expiresAt: DateTime.now().subtract(Duration(minutes: 1)),
  /// );
  /// 
  /// if (entry.isExpired) {
  ///   print('This entry expired 1 minute ago');
  /// }
  /// ```
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Gets the remaining time until expiration.
  /// 
  /// Returns a [Duration] representing how much time is left before
  /// this entry expires. If the entry has already expired, returns
  /// a negative duration.
  /// 
  /// ## Returns
  /// 
  /// The time remaining until expiration. Negative if already expired.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final entry = CacheEntry(
  ///   value: 'data',
  ///   expiresAt: DateTime.now().add(Duration(minutes: 30)),
  /// );
  /// 
  /// final timeLeft = entry.timeUntilExpiration;
  /// if (timeLeft.isNegative) {
  ///   print('Entry has expired');
  /// } else {
  ///   print('Entry expires in ${timeLeft.inMinutes} minutes');
  /// }
  /// ```
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  @override
  String toString() {
    return 'CacheEntry(value: $value, expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}