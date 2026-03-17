import 'dart:typed_data';

class MemoryCache {
  final Map<String, Uint8List> _cache = {};

  Uint8List? get(String key) {
    return _cache[key];
  }

  void set(String key, Uint8List bytes) {
    _cache[key] = bytes;
  }

  void clear() {
    _cache.clear();
  }
}
