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
            placeholder: const Center(child: CircularProgressIndicator()),
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
