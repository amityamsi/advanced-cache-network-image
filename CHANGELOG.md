# Changelog

All notable changes to this project will be documented in this file.

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