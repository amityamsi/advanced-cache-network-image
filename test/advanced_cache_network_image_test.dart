import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';

void main() {
  group('AdvancedCacheNetworkImage Tests', () {
    test('Widget should create successfully', () {
      const widget = AdvancedCacheNetworkImage(
        url: "https://example.com/test.png",
      );

      expect(widget.url, "https://example.com/test.png");
    });

    test('URL should not be empty', () {
      const widget = AdvancedCacheNetworkImage(
        url: "https://example.com/image.jpg",
      );

      expect(widget.url.isNotEmpty, true);
    });
  });
}
