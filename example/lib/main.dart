import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageCustomizationScreen(),
    );
  }
}

class ImageCustomizationScreen extends StatefulWidget {
  const ImageCustomizationScreen({super.key});

  @override
  State<ImageCustomizationScreen> createState() =>
      _ImageCustomizationScreenState();
}

class _ImageCustomizationScreenState extends State<ImageCustomizationScreen> {
  bool useMemoryCache = true;
  bool useDiskCache = true;
  bool enableFade = true;

  int maxRetries = 3;
  int maxConcurrentDownloads = 3;
  int targetWidth = 700;
  double radius = 16;

  int cacheDays = 3;

  CancelToken cancelToken = CancelToken();
  late ImageLoader loader;

  static const String demoUrl = 'https://picsum.photos/1600/1000';

  ImageLoader _createLoader() {
    return ImageLoader(
      timeout: const Duration(seconds: 20),
      maxRetries: maxRetries,
      baseDelay: const Duration(milliseconds: 400),
      maxConcurrentDownloads: maxConcurrentDownloads,
    );
  }

  @override
  void initState() {
    super.initState();
    loader = _createLoader();
  }

  void _rebuildLoader() {
    setState(() {
      loader = _createLoader();
    });
  }

  void _cancelCurrentDownload() {
    cancelToken.cancel();
    setState(() {
      cancelToken = CancelToken();
    });
  }

  Future<void> _clearImageCaches() async {
    await loader.evict(demoUrl);
    loader.clearMemoryCache();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleared memory + disk cache for demo URL')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final imageKey = ValueKey(
      '$useMemoryCache-$useDiskCache-$enableFade-$maxRetries-'
      '$maxConcurrentDownloads-$targetWidth-$radius-$cacheDays',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Cache Image Playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Update these controls to customize behavior',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Use memory cache'),
                    value: useMemoryCache,
                    onChanged: (value) => setState(() => useMemoryCache = value),
                  ),
                  SwitchListTile(
                    title: const Text('Use disk cache'),
                    value: useDiskCache,
                    onChanged: (value) => setState(() => useDiskCache = value),
                  ),
                  SwitchListTile(
                    title: const Text('Enable fade animation'),
                    value: enableFade,
                    onChanged: (value) => setState(() => enableFade = value),
                  ),
                  const SizedBox(height: 8),
                  Text('Max retries: $maxRetries'),
                  Slider(
                    min: 0,
                    max: 6,
                    divisions: 6,
                    value: maxRetries.toDouble(),
                    label: '$maxRetries',
                    onChanged: (value) {
                      maxRetries = value.toInt();
                      _rebuildLoader();
                    },
                  ),
                  Text('Max concurrent downloads: $maxConcurrentDownloads'),
                  Slider(
                    min: 1,
                    max: 8,
                    divisions: 7,
                    value: maxConcurrentDownloads.toDouble(),
                    label: '$maxConcurrentDownloads',
                    onChanged: (value) {
                      maxConcurrentDownloads = value.toInt();
                      _rebuildLoader();
                    },
                  ),
                  Text('Decode target width: $targetWidth'),
                  Slider(
                    min: 200,
                    max: 1400,
                    divisions: 12,
                    value: targetWidth.toDouble(),
                    label: '$targetWidth',
                    onChanged: (value) => setState(() => targetWidth = value.toInt()),
                  ),
                  Text('Border radius: ${radius.toStringAsFixed(0)}'),
                  Slider(
                    min: 0,
                    max: 32,
                    divisions: 16,
                    value: radius,
                    label: radius.toStringAsFixed(0),
                    onChanged: (value) => setState(() => radius = value),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Cache duration (days)',
                      border: OutlineInputBorder(),
                    ),
                    value: cacheDays,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 day')),
                      DropdownMenuItem(value: 3, child: Text('3 days')),
                      DropdownMenuItem(value: 7, child: Text('7 days')),
                      DropdownMenuItem(value: 30, child: Text('30 days')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => cacheDays = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: _cancelCurrentDownload,
                        child: const Text('Cancel Current Download'),
                      ),
                      OutlinedButton(
                        onPressed: _clearImageCaches,
                        child: const Text('Clear Demo Cache'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Live preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AdvancedCacheNetworkImage(
            key: imageKey,
            url: demoUrl,
            imageLoader: loader,
            cancelToken: cancelToken,
            useMemoryCache: useMemoryCache,
            useDiskCache: useDiskCache,
            cacheDuration: Duration(days: cacheDays),
            targetWidth: targetWidth,
            height: 230,
            fit: BoxFit.cover,
            radius: radius,
            enableFade: enableFade,
            progressBuilder: (context, progress) {
              return Center(
                child: CircularProgressIndicator(
                  value: progress == 0 ? null : progress,
                ),
              );
            },
            errorWidget: const Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          ),
        ],
      ),
    );
  }
}
