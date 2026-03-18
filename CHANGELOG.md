# Changelog

All notable changes to this project will be documented in this file.

---

## 0.0.3

### 🚀 API Enhancements

- Added advanced user configurability in `ImageLoader`:
  - `timeout`
  - `maxRetries`
  - `baseDelay`
  - `maxConcurrentDownloads`
- Made queue concurrency runtime-configurable through `ViewportPriorityQueue.maxConcurrent`
- Extended `loadBytes(...)` to support:
  - `useMemoryCache`
  - `useDiskCache`
  - `cacheDuration`
- Added `ImageLoader.shared` for reusable shared caching/dedup flows
- Added cache control APIs:
  - `ImageLoader.evict(...)`
  - `ImageLoader.clearMemoryCache()`
- Added widget-level customization in `AdvancedCacheNetworkImage`:
  - `imageLoader` (inject custom loader)
  - `cancelToken` (cancel in-flight request)
- Wired widget cache flags/duration into byte-loading flow so cache options now apply during normal widget usage
- Exported advanced classes from package root so users no longer need `src/` imports:
  - `ImageLoader`
  - `MemoryCache`
  - `DiskCache`
  - `NetworkFetcher`
  - `CancelToken`
  - `ViewportPriorityQueue`

### 📚 Documentation

- Rewrote `README.md` with a complete package overview and accurate feature list
- Updated installation instructions to `advanced_cache_network_image: ^0.0.3`
- Added a clear "What You Can Update" section to document customizable widget, loader, and queue options
- Added practical usage examples:
  - Basic image loading
  - Progress + error handling
  - Decode resizing (`targetWidth`, `targetHeight`)
  - Prefetch flow with `ImageLoader.prefetch(...)`
  - Advanced customization and manual cache control (`evict`, `clearMemoryCache`)
- Added a clear widget parameter reference section
- Added implementation notes to clarify current cache behavior and queue limits
- Added a new troubleshooting section for:
  - Invalid URL failures
  - Stale cache behavior
  - Indeterminate progress when `content-length` is unavailable

### 🧪 Example App

- Rebuilt `example/lib/main.dart` as a live customization playground
- Added interactive controls for:
  - memory/disk cache toggles
  - fade animation toggle
  - max retries
  - max concurrent downloads
  - decode target width
  - border radius
  - cache duration
- Added demo actions to cancel in-flight download and clear demo cache

---

## 0.0.2

### 📚 Documentation Improvements

- Added comprehensive **dartdoc comments** across all public APIs
- Improved documentation for:
  - `AdvancedCacheNetworkImage`
  - `ImageLoader`
  - `MemoryCache`
  - `DiskCache`
  - `NetworkFetcher`
  - `ViewportPriorityQueue`
- Added detailed method, property, and usage explanations
- Improved inline comments for better code readability

---

### ⚙️ Enhancements

- Added proper **error handling** in network requests
- Improved **download queue stability** with safer async execution
- Refined internal documentation for caching flow and architecture

---

### 🧪 Maintenance

- Increased public API documentation coverage to meet **pub.dev standards**
- Minor internal code cleanup and consistency improvements

---

## 0.0.1

Initial release of **advanced_cache_network_image**.

### ✨ Features

- Network image widget with disk and memory caching
- LRU memory cache implementation
- Disk cache with configurable expiration
- Download queue to limit simultaneous requests
- Viewport priority loading for smoother scrolling
- Progressive image rendering (low resolution preview → full resolution)
- Prefetch API for preloading images
- Configurable cache duration
- Optional memory cache / disk cache control
- Border radius support
- Custom placeholder widget
- Custom error widget
- Image resizing before decoding for improved performance

---

### 📱 Example

Added example application demonstrating:

- Thumbnail images
- Low resolution images
- HD images
- 4K images
- Ultra high resolution images
