import 'dart:typed_data';

/// A simple in-memory cache for storing image bytes.
///
/// This cache stores images using a key (usually the image URL)
/// and keeps them in memory for fast access.
///
/// Useful for:
/// - Avoiding repeated decoding
/// - Reducing disk reads
/// - Improving scroll performance in image-heavy UIs
///
/// Note:
/// This is a basic implementation and does not include eviction logic.
/// For large-scale usage, consider implementing an LRU strategy.
class MemoryCache {
  /// Internal map storing cached image bytes.
  final Map<String, Uint8List> _cache = {};

  /// Retrieves cached bytes for the given [key].
  ///
  /// Returns `null` if the item is not found in cache.
  Uint8List? get(String key) {
    return _cache[key];
  }

  /// Stores image [bytes] in cache with the given [key].
  ///
  /// If the key already exists, it will be overwritten.
  void set(String key, Uint8List bytes) {
    _cache[key] = bytes;
  }

  /// Clears all cached items from memory.
  ///
  /// Useful for freeing up memory or resetting cache state.
  void clear() {
    _cache.clear();
  }
}
