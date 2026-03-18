import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'memory_cache.dart';
import 'disk_cache.dart';
import 'network_fetcher.dart';
import 'viewport_priority_queue.dart';

/// A high-performance image loading manager.
///
/// Features:
/// - Memory cache (LRU)
/// - Disk cache
/// - Network fetching
/// - Viewport priority queue
/// - 🔥 Request deduplication
/// - 🔥 Shared progress listeners
/// - 🔥 Cancel support
///
/// Designed for image-heavy UIs like feeds and grids.
class ImageLoader {
  /// Shared loader instance that can be reused across widgets/screens.
  static final ImageLoader shared = ImageLoader();

  /// In-memory cache
  final MemoryCache memoryCache;

  /// Disk cache
  final DiskCache diskCache;

  /// Network handler
  final NetworkFetcher networkFetcher;

  /// 🔥 Tracks ongoing requests (URL → Future)
  final Map<String, Future<Uint8List>> _ongoingRequests = {};

  /// 🔥 Progress listeners (URL → Listeners)
  final Map<String, List<void Function(int, int?)>> _progressListeners = {};

  ImageLoader({
    MemoryCache? memoryCache,
    DiskCache? diskCache,
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 500),
    int? maxConcurrentDownloads,
  })  : memoryCache = memoryCache ?? MemoryCache(),
        diskCache = diskCache ?? DiskCache(),
        networkFetcher = NetworkFetcher(
          timeout: timeout,
          maxRetries: maxRetries,
          baseDelay: baseDelay,
        ) {
    if (maxConcurrentDownloads != null && maxConcurrentDownloads > 0) {
      ViewportPriorityQueue.maxConcurrent = maxConcurrentDownloads;
    }
  }

  /// Loads image as File (disk-backed)
  Future<File> load(
    String url, {
    Duration? cacheDuration,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    /// 1️⃣ MEMORY CACHE
    if (useMemoryCache) {
      final memory = memoryCache.get(url);
      if (memory != null) {
        final file = await diskCache.getFile(url);
        await file.writeAsBytes(memory);
        return file;
      }
    }

    /// 2️⃣ DISK CACHE
    final file = await diskCache.getFile(url);

    if (useDiskCache && await file.exists()) {
      if (cacheDuration != null) {
        final modified = await file.lastModified();

        if (DateTime.now().difference(modified) <= cacheDuration) {
          return file;
        }

        await file.delete();
      } else {
        return file;
      }
    }

    /// 3️⃣ DOWNLOAD
    final bytes = await loadBytes(
      url,
      cacheDuration: cacheDuration,
      useMemoryCache: useMemoryCache,
      useDiskCache: useDiskCache,
    );

    await file.writeAsBytes(bytes);
    return file;
  }

  /// Prefetch image into cache
  Future<void> prefetch(String url) async {
    await loadBytes(url);
  }

  /// Removes a specific URL from cache.
  Future<void> evict(
    String url, {
    bool memory = true,
    bool disk = true,
  }) async {
    if (memory) {
      memoryCache.remove(url);
    }

    if (disk) {
      final file = await diskCache.getFile(url);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Clears only in-memory cache.
  void clearMemoryCache() {
    memoryCache.clear();
  }

  /// Loads image bytes with full optimization pipeline
  Future<Uint8List> loadBytes(
    String url, {
    void Function(int received, int? total)? onProgress,
    CancelToken? cancelToken,
    Duration? cacheDuration,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    /// 1️⃣ MEMORY CACHE
    if (useMemoryCache) {
      final memory = memoryCache.get(url);
      if (memory != null) {
        onProgress?.call(memory.length, memory.length);
        return memory;
      }
    }

    /// 2️⃣ DISK CACHE
    final file = await diskCache.getFile(url);
    if (useDiskCache && await file.exists()) {
      bool isValid = true;

      if (cacheDuration != null) {
        final modified = await file.lastModified();
        isValid = DateTime.now().difference(modified) <= cacheDuration;
      }

      if (isValid) {
        final bytes = await file.readAsBytes();
        if (useMemoryCache) {
          memoryCache.set(url, bytes);
        }
        onProgress?.call(bytes.length, bytes.length);
        return bytes;
      }

      await file.delete();
    }

    /// 3️⃣ 🔥 REQUEST DEDUPLICATION
    if (_ongoingRequests.containsKey(url)) {
      if (onProgress != null) {
        _progressListeners[url]?.add(onProgress);
      }
      return _ongoingRequests[url]!;
    }

    /// 4️⃣ REGISTER PROGRESS LISTENER
    if (onProgress != null) {
      _progressListeners.putIfAbsent(url, () => []);
      _progressListeners[url]!.add(onProgress);
    }

    /// 5️⃣ CREATE REQUEST
    final future = _downloadAndCache(
      url,
      cancelToken: cancelToken,
      useMemoryCache: useMemoryCache,
      useDiskCache: useDiskCache,
    );

    _ongoingRequests[url] = future;

    try {
      return await future;
    } finally {
      /// 🔥 CLEANUP
      _ongoingRequests.remove(url);
      _progressListeners.remove(url);
    }
  }

  /// Internal download handler with:
  /// - Priority queue
  /// - Shared progress broadcasting
  /// - Cancel support
  Future<Uint8List> _downloadAndCache(
    String url, {
    CancelToken? cancelToken,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    final completer = Completer<Uint8List>();

    ViewportPriorityQueue.add(() async {
      try {
        final bytes = await networkFetcher.download(
          url,
          cancelToken: cancelToken,
          onProgress: (received, total) {
            final listeners = _progressListeners[url];
            if (listeners != null) {
              for (final listener in listeners) {
                listener(received, total);
              }
            }
          },
        );

        completer.complete(bytes);
      } catch (e) {
        completer.completeError(e);
      }
    });

    final bytes = await completer.future;

    /// Store in memory
    if (useMemoryCache) {
      memoryCache.set(url, bytes);
    }

    /// Store in disk
    if (useDiskCache) {
      final file = await diskCache.getFile(url);
      await file.writeAsBytes(bytes);
    }

    return bytes;
  }
}
