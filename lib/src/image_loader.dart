import 'dart:async';
import 'dart:io';

import 'package:advanced_cache_network_image/src/viewport_priority_queue.dart';

import 'memory_cache.dart';
import 'disk_cache.dart';
import 'network_fetcher.dart';

import 'dart:typed_data';

/// A high-level image loading manager that handles fetching,
/// caching, and prioritizing image downloads.
///
/// This class combines:
/// - Memory cache (LRU)
/// - Disk cache
/// - Network downloading
/// - Viewport-based priority queue
///
/// It ensures optimal performance for image-heavy UIs like feeds.
class ImageLoader {
  /// In-memory cache for storing frequently used images.
  final MemoryCache memoryCache = MemoryCache();

  /// Disk cache for persistent image storage.
  final DiskCache diskCache = DiskCache();

  /// Network handler responsible for downloading images.
  final NetworkFetcher networkFetcher = NetworkFetcher();

  /// Loads an image and returns it as a cached [File].
  ///
  /// This method follows a multi-layer caching strategy:
  ///
  /// 1. Check memory cache
  /// 2. Check disk cache
  /// 3. Download from network (via priority queue)
  /// 4. Store in memory and disk cache
  ///
  /// Parameters:
  /// - [url]: Image URL
  /// - [targetWidth], [targetHeight]: Optional resize hints
  /// - [cacheDuration]: Expiration duration for disk cache
  /// - [useMemoryCache]: Enable/disable memory caching
  /// - [useDiskCache]: Enable/disable disk caching
  Future<File> load(
    String url, {
    int? targetWidth,
    int? targetHeight,
    Duration? cacheDuration,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    Uint8List? bytes;

    /// Step 1: MEMORY CACHE
    if (useMemoryCache) {
      final memory = memoryCache.get(url);

      if (memory != null) {
        final file = await diskCache.getFile(url);
        await file.writeAsBytes(memory);
        return file;
      }
    }

    /// Step 2: DISK CACHE
    final file = await diskCache.getFile(url);

    if (useDiskCache && await file.exists()) {
      if (cacheDuration != null) {
        final modified = await file.lastModified();

        /// Check if cache is still valid
        if (DateTime.now().difference(modified) <= cacheDuration) {
          return file;
        }

        /// Cache expired → delete
        await file.delete();
      } else {
        return file;
      }
    }

    /// Step 3: DOWNLOAD (with viewport priority queue)
    final completer = Completer<Uint8List>();

    ViewportPriorityQueue.add(() async {
      final downloaded = await networkFetcher.download(url);
      completer.complete(downloaded);
    });

    bytes = await completer.future;

    /// Step 4: STORE IN MEMORY CACHE
    if (useMemoryCache) {
      memoryCache.set(url, bytes);
    }

    /// Step 5: STORE IN DISK CACHE
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Prefetches an image and stores it in cache.
  ///
  /// This is useful for:
  /// - Preloading images before they appear on screen
  /// - Improving scroll performance in feeds
  ///
  /// Example:
  /// ```dart
  /// ImageLoader().prefetch("https://example.com/image.jpg");
  /// ```
  Future<void> prefetch(String url) async {
    await load(url);
  }

  /// Loads image bytes directly.
  ///
  /// This method:
  /// - Checks memory cache first
  /// - Falls back to disk cache
  /// - Downloads from network if needed
  ///
  /// Unlike [load], this returns raw [Uint8List] instead of a file.
  Future<Uint8List> loadBytes(String url) async {
    /// Step 1: MEMORY CACHE
    final memory = memoryCache.get(url);

    if (memory != null) {
      return memory;
    }

    /// Step 2: DISK CACHE
    final file = await diskCache.getFile(url);

    if (await file.exists()) {
      final bytes = await file.readAsBytes();

      memoryCache.set(url, bytes);

      return bytes;
    }

    /// Step 3: NETWORK DOWNLOAD
    final bytes = await networkFetcher.download(url);

    /// Store in memory
    memoryCache.set(url, bytes);

    /// Store on disk
    await file.writeAsBytes(bytes);

    return bytes;
  }
}
