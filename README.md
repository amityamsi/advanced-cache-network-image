# advanced_cache_network_image

A high-performance Flutter widget for loading and caching network images with advanced optimizations such as **LRU memory cache, disk cache, progressive preview rendering, download queue, and viewport priority loading**.

This package is designed for **fast image loading in large feeds**, inspired by techniques used in social media apps.

---

# ✨ Features

• LRU **Memory Cache**  
• **Disk Cache** with configurable expiration  
• **Download Queue** to limit simultaneous downloads  
• **Viewport Priority Loading** for smoother scrolling  
• **Progressive image rendering** (low resolution preview → high resolution)  
• **Prefetch API** for preloading images  
• Configurable **cache duration**  
• Optional **memory cache / disk cache control**  
• **Rounded corner support**  
• Custom **placeholder widget**  
• Custom **error widget**  
• Image **resize before decoding** for better performance

---

# 🚀 Getting Started

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  advanced_cache_network_image: ^0.0.1
```

Run:

```bash
flutter pub get
```

---

# 📦 Usage

Import the package:

```dart
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';
```

Basic usage:

```dart
AdvancedCacheNetworkImage(
  url: "https://picsum.photos/400",
)
```

---

# 📷 Full Example

```dart
import 'package:flutter/material.dart';
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageExampleScreen(),
    );
  }
}

class ImageExampleScreen extends StatelessWidget {
  const ImageExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Cache Network Image"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Thumbnail (150px)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          AdvancedCacheNetworkImage(
            url: "https://picsum.photos/150",
            height: 200,
            fit: BoxFit.cover,
            radius: 16,
          ),

          const SizedBox(height: 30),

          const Text(
            "Low Resolution (640px)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          AdvancedCacheNetworkImage(
            url: "https://picsum.photos/640/400",
            height: 200,
            fit: BoxFit.cover,
            radius: 16,
          ),

          const SizedBox(height: 30),

          const Text(
            "HD Image (1280px)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          AdvancedCacheNetworkImage(
            url: "https://picsum.photos/1280/720",
            height: 200,
            fit: BoxFit.cover,
            radius: 16,
          ),

          const SizedBox(height: 30),

          const Text(
            "4K Image (3840px)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          AdvancedCacheNetworkImage(
            url: "https://picsum.photos/3840/2160",
            height: 200,
            fit: BoxFit.cover,
            radius: 16,
            targetWidth: 400,
            cacheDuration: const Duration(days: 7),
            placeholder: const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: const Icon(Icons.broken_image),
          ),

          const SizedBox(height: 30),

          const Text(
            "Ultra High Resolution (4000px)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          AdvancedCacheNetworkImage(
            url: "https://picsum.photos/4000/3000",
            height: 200,
            fit: BoxFit.cover,
            radius: 16,
          ),

          const SizedBox(height: 30),

        ],
      ),
    );
  }
}
```

---

# ⚡ Progressive Image Rendering

The package improves perceived performance by rendering a preview first:

```
Download image bytes
      ↓
Decode small preview
      ↓
Display preview
      ↓
Decode full resolution
      ↓
Replace preview smoothly
```

This technique makes image-heavy feeds feel much faster.

---

# 🔄 Prefetch Images

Images can be preloaded before displaying them.

```dart
ImageLoader().prefetch("https://example.com/image.jpg");
```

Useful for:

- feed scrolling
- gallery screens
- upcoming images

---

# 🧠 Performance Optimizations

### Memory Cache (LRU)

Frequently used images are stored in memory and automatically evicted when the cache limit is reached.

### Disk Cache

Images are stored locally to avoid repeated downloads.

### Download Queue

Limits concurrent downloads to prevent network congestion.

### Viewport Priority Loading

Images visible on screen load first, improving scroll performance.

---

# 📱 Example App

See the `/example` folder for a full demonstration including:

- thumbnail images
- low resolution images
- HD images
- 4K images
- ultra high resolution images

---

# 🤝 Contributing

Contributions, bug reports, and feature requests are welcome.

Feel free to open an issue or submit a pull request.

---

# 📄 License

MIT License
# advanced-cache-network-image
