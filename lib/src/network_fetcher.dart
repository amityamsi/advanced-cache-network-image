import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

/// A high-performance network image downloader with:
/// - Streaming
/// - Progress tracking
/// - Cancellation
/// - 🔥 Exponential retry with backoff
/// - Timeout handling
class NetworkFetcher {
  /// Request timeout duration
  final Duration timeout;

  /// Maximum retry attempts
  final int maxRetries;

  /// Base delay for exponential backoff
  final Duration baseDelay;

  NetworkFetcher({
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  /// Downloads image bytes with retry + backoff support
  Future<Uint8List> download(
    String url, {
    void Function(int received, int? total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await _downloadOnce(
          url,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
      } catch (e) {
        attempt++;

        /// ❌ Stop retrying if:
        if (!_shouldRetry(e) ||
            attempt > maxRetries ||
            cancelToken?.isCancelled == true) {
          rethrow;
        }

        /// ⏳ Exponential backoff delay
        final delay = _calculateDelay(attempt);

        await Future.delayed(delay);
      }
    }
  }

  /// Single attempt download
  Future<Uint8List> _downloadOnce(
    String url, {
    void Function(int received, int? total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final uri = Uri.parse(url);

    HttpClient? client;

    try {
      client = HttpClient();

      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);

      /// Validate response
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      final total = response.contentLength;
      int received = 0;

      final bytes = <int>[];

      await for (final chunk in response) {
        /// 🔥 Cancel support
        if (cancelToken?.isCancelled == true) {
          throw Exception('Download cancelled');
        }

        bytes.addAll(chunk);
        received += chunk.length;

        /// 📊 Progress
        onProgress?.call(received, total > 0 ? total : null);
      }

      return Uint8List.fromList(bytes);
    } finally {
      client?.close(force: true);
    }
  }

  /// Determines if request should retry
  bool _shouldRetry(Object error) {
    /// Retry only for network/server issues
    return error is SocketException ||
        error is TimeoutException ||
        (error is HttpException && _isServerError(error));
  }

  /// Detect server-side errors (5xx)
  bool _isServerError(HttpException e) {
    final message = e.message;
    return message.contains('500') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('504');
  }

  /// Calculates exponential delay
  Duration _calculateDelay(int attempt) {
    /// 500ms, 1s, 2s, 4s...
    final ms = baseDelay.inMilliseconds * (1 << (attempt - 1));
    return Duration(milliseconds: ms);
  }
}

/// Cancellation token to stop ongoing downloads
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}
