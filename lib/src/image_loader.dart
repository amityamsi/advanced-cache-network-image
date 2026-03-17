import 'dart:async';
import 'dart:io';

import 'package:advanced_cache_network_image/src/viewport_priority_queue.dart';

import 'memory_cache.dart';
import 'disk_cache.dart';
import 'network_fetcher.dart';

import 'dart:typed_data';

class ImageLoader {
  final MemoryCache memoryCache = MemoryCache();
  final DiskCache diskCache = DiskCache();
  final NetworkFetcher networkFetcher = NetworkFetcher();

  Future<File> load(
    String url, {
    int? targetWidth,
    int? targetHeight,
    Duration? cacheDuration,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    Uint8List? bytes;

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

    /// 3️⃣ DOWNLOAD WITH PRIORITY QUEUE
    final completer = Completer<Uint8List>();

    ViewportPriorityQueue.add(() async {
      final downloaded = await networkFetcher.download(url);
      completer.complete(downloaded);
    });

    bytes = await completer.future;

    /// 4️⃣ MEMORY CACHE STORE
    if (useMemoryCache) {
      memoryCache.set(url, bytes);
    }

    /// 5️⃣ DISK CACHE STORE
    await file.writeAsBytes(bytes);

    return file;
  }

  /// PREFETCH
  Future<void> prefetch(String url) async {
    await load(url);
  }

  Future<Uint8List> loadBytes(String url) async {
    final memory = memoryCache.get(url);

    if (memory != null) {
      return memory;
    }

    final file = await diskCache.getFile(url);

    if (await file.exists()) {
      final bytes = await file.readAsBytes();

      memoryCache.set(url, bytes);

      return bytes;
    }

    final bytes = await networkFetcher.download(url);

    memoryCache.set(url, bytes);

    await file.writeAsBytes(bytes);

    return bytes;
  }
}
