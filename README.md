# advanced_cache_network_image

Advanced Flutter network image loading with memory + disk cache, request deduplication, progress callbacks, queue-based concurrency, and retry support.

## Features

- Widget-first API: `AdvancedCacheNetworkImage`
- Memory caching (`MemoryCache`)
- Disk caching in temporary directory (`DiskCache`)
- Request deduplication (same URL shares one in-flight request)
- Shared progress listeners for duplicate requests
- Download queue with configurable concurrency (`ViewportPriorityQueue.maxConcurrent`, default `3`)
- Retry with exponential backoff for transient network/server failures
- Optional decode sizing (`targetWidth`, `targetHeight`) for large images
- Placeholder, progress, error, and custom image builder support
- Prefetch support through `ImageLoader.prefetch(...)`

## Install

```yaml
dependencies:
  advanced_cache_network_image: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';

AdvancedCacheNetworkImage(
  url: 'https://picsum.photos/1200/800',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  radius: 12,
)
```

## Usage with Progress + Error UI

```dart
AdvancedCacheNetworkImage(
  url: 'https://picsum.photos/800/500',
  height: 220,
  fit: BoxFit.cover,
  progressBuilder: (context, progress) {
    return Center(
      child: CircularProgressIndicator(
        value: progress == 0 ? null : progress,
      ),
    );
  },
  errorWidget: const Center(
    child: Icon(Icons.broken_image),
  ),
)
```

## Resize During Decode

```dart
AdvancedCacheNetworkImage(
  url: 'https://picsum.photos/3840/2160',
  targetWidth: 800,
  targetHeight: 450,
  fit: BoxFit.cover,
)
```

## Prefetch Example

```dart
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';

final loader = ImageLoader();
await loader.prefetch('https://picsum.photos/1200/800');
```

You can also control cache manually:

```dart
await loader.evict('https://picsum.photos/1200/800'); // remove one URL
loader.clearMemoryCache(); // clear memory cache only
```

## Advanced Customization

```dart
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';

final loader = ImageLoader(
  timeout: const Duration(seconds: 20),
  maxRetries: 5,
  baseDelay: const Duration(milliseconds: 400),
  maxConcurrentDownloads: 6,
);

final cancelToken = CancelToken();

AdvancedCacheNetworkImage(
  url: 'https://example.com/image.jpg',
  imageLoader: loader,
  cancelToken: cancelToken,
  useMemoryCache: true,
  useDiskCache: true,
  cacheDuration: const Duration(days: 3),
);

// later: cancel if needed
cancelToken.cancel();
```

## What You Can Update

### 1) Widget-level options (`AdvancedCacheNetworkImage`)

- URL and rendering: `url`, `fit`, `width`, `height`, `radius`
- Loading UI: `placeholder`, `progressBuilder`, `errorWidget`
- Decode size: `targetWidth`, `targetHeight`
- Animation: `enableFade`, `fadeDuration`
- Cache usage per widget: `useMemoryCache`, `useDiskCache`, `cacheDuration`
- Advanced wiring: `imageLoader`, `cancelToken`, `imageBuilder`

### 2) Loader-level options (`ImageLoader`)

- Network behavior: `timeout`, `maxRetries`, `baseDelay`
- Download concurrency: `maxConcurrentDownloads`
- Cache lifecycle:
  - `prefetch(url)`
  - `evict(url, memory: true, disk: true)`
  - `clearMemoryCache()`

### 3) Global queue option (`ViewportPriorityQueue`)

- Update queue concurrency at runtime:

```dart
ViewportPriorityQueue.maxConcurrent = 6;
```

### Practical Pattern

```dart
final loader = ImageLoader(
  timeout: const Duration(seconds: 20),
  maxRetries: 4,
  maxConcurrentDownloads: 5,
);

AdvancedCacheNetworkImage(
  url: 'https://example.com/image.jpg',
  imageLoader: loader,
  useMemoryCache: true,
  useDiskCache: true,
  cacheDuration: const Duration(days: 7),
  targetWidth: 900,
  enableFade: true,
);
```

## Widget Parameters

- `url` (required): image URL
- `fit`: `BoxFit` for rendering
- `placeholder`: widget shown while loading
- `progressBuilder`: builder with progress (`0.0` to `1.0`)
- `errorWidget`: widget shown on failure
- `width`, `height`: optional layout sizing
- `radius`: border radius applied with `ClipRRect`
- `targetWidth`, `targetHeight`: decode size hints
- `cacheDuration`: disk cache expiration check (when used in file-based load flow)
- `useMemoryCache`, `useDiskCache`: cache toggles
- `enableFade`, `fadeDuration`: animated transitions
- `imageBuilder`: full control over final image rendering
- `imageLoader`: inject your own `ImageLoader` instance
- `cancelToken`: cancel an in-flight request

## Notes

- Disk cache files are stored in the platform temporary directory.
- Memory cache is currently a simple in-memory map (no LRU eviction yet).
- `prefetch` and low-level cache/network APIs are available from `ImageLoader`.

## Troubleshooting

- Invalid URL
  Cause: malformed URL, DNS issue, or non-200 server response.
  Fix: verify the URL in a browser/Postman, ensure it starts with `http://` or `https://`, and provide an `errorWidget` to handle failures gracefully.
- Cache seems stale
  Cause: cached bytes are reused from memory/disk.
  Fix: use a cache-busting query (for example `?v=timestamp`), set an appropriate `cacheDuration` in file-based flows, or clear/restart app state during development.
- Progress stuck at indeterminate
  Cause: server does not send `content-length`, so total size is unknown.
  Fix: this is expected for some endpoints; keep showing indeterminate progress (`value: null`) until completion, or switch to a different endpoint/CDN that returns `content-length`.

## Example App

See the runnable sample in:

- `example/lib/main.dart`
- The example screen now includes a live customization panel (toggles + sliders) so you can test most settings directly.

## License

MIT - see `LICENSE`.
