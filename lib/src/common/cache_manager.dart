import 'dart:async';

/// Simple in-memory cache for auth tokens and voices
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, CacheEntry> _cache = {};

  void put<T>(String key, T value, Duration ttl) {
    _cache[key] = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  const CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  final dynamic value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}