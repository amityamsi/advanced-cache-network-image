import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// A utility class responsible for downloading image data from the network.
///
/// This class handles HTTP requests and returns raw image bytes,
/// which can then be cached in memory or on disk.
///
/// Used internally by [ImageLoader] as the final fallback
/// when the image is not available in cache.
class NetworkFetcher {
  /// Downloads image data from the given [url].
  ///
  /// Returns the image as [Uint8List] bytes.
  ///
  /// Throws an exception if the network request fails.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await NetworkFetcher().download(
  ///   "https://example.com/image.jpg",
  /// );
  /// ```
  Future<Uint8List> download(String url) async {
    final response = await http.get(Uri.parse(url));

    return response.bodyBytes;
  }
}
