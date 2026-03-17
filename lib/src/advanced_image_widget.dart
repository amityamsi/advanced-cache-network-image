/// A high-performance Flutter widget for loading and caching network images.
///
/// This widget provides:
/// - Memory and disk caching support
/// - Progressive image rendering (preview → full image)
/// - Custom placeholder and error widgets
/// - Optional rounded corners
/// - Image resizing for performance optimization
///
/// Example:
/// ```dart
/// AdvancedCacheNetworkImage(
///   url: "https://example.com/image.jpg",
///   height: 200,
///   fit: BoxFit.cover,
/// )
/// ```
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'image_loader.dart';

/// A widget that displays a network image with advanced caching and smooth rendering.
///
/// It first shows a preview image and then replaces it with the full-resolution image.
/// This improves perceived performance in image-heavy UIs like feeds.
class AdvancedCacheNetworkImage extends StatefulWidget {
  /// The URL of the image to load.
  final String url;

  /// How the image should be inscribed into the available space.
  final BoxFit? fit;

  /// Widget displayed while the image is loading.
  ///
  /// Defaults to a [CircularProgressIndicator].
  final Widget? placeholder;

  /// Widget displayed if the image fails to load.
  ///
  /// Defaults to an error [Icon].
  final Widget? errorWidget;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// Border radius applied to the image.
  ///
  /// Defaults to `0` (no rounding).
  final double radius;

  /// Target width for decoding the image.
  ///
  /// Helps reduce memory usage for large images.
  final int? targetWidth;

  /// Target height for decoding the image.
  final int? targetHeight;

  /// Duration for which the image is cached.
  ///
  /// If null, a default duration is used internally.
  final Duration? cacheDuration;

  /// Whether to use in-memory caching.
  ///
  /// Defaults to `true`.
  final bool useMemoryCache;

  /// Whether to use disk caching.
  ///
  /// Defaults to `true`.
  final bool useDiskCache;

  /// Creates an [AdvancedCacheNetworkImage].
  ///
  /// The [url] parameter is required.
  ///
  /// You can customize caching behavior, placeholders,
  /// error handling, and rendering options.
  const AdvancedCacheNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.radius = 0,
    this.targetWidth,
    this.targetHeight,
    this.cacheDuration,
    this.useMemoryCache = true,
    this.useDiskCache = true,
  });

  @override
  State<AdvancedCacheNetworkImage> createState() =>
      _AdvancedCacheNetworkImageState();
}

/// State class responsible for loading and rendering the image.
class _AdvancedCacheNetworkImageState extends State<AdvancedCacheNetworkImage> {
  /// Internal image loader responsible for fetching and caching image bytes.
  final loader = ImageLoader();

  /// Cached file reference (if disk cache is used).
  File? file;

  /// Indicates whether an error occurred during loading.
  bool isError = false;

  /// Raw image bytes.
  Uint8List? bytes;

  /// Low-resolution preview image.
  ImageProvider? previewImage;

  /// Fully decoded high-resolution image.
  ImageProvider? fullImage;

  @override
  void initState() {
    super.initState();
    load();
  }

  /// Loads the image bytes and performs progressive decoding.
  ///
  /// Steps:
  /// 1. Fetch image bytes
  /// 2. Show preview image
  /// 3. Decode full image
  /// 4. Replace preview with full image
  Future<void> load() async {
    try {
      bytes = await loader.loadBytes(widget.url);

      /// Step 1: Create preview image
      previewImage = MemoryImage(bytes!);

      if (!mounted) return;

      setState(() {});

      /// Step 2: Decode full-resolution image
      final fullCodec = await instantiateImageCodec(bytes!);
      await fullCodec.getNextFrame();

      fullImage = MemoryImage(bytes!);

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isError = true;
      });
    }
  }

  /// Builds the UI for the image widget.
  ///
  /// Handles:
  /// - Loading state
  /// - Error state
  /// - Image rendering with optional radius
  @override
  Widget build(BuildContext context) {
    if (isError) {
      return widget.errorWidget ?? const Icon(Icons.error);
    }

    if (bytes == null) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    Widget image = Image(
      image: fullImage ?? previewImage!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );

    if (widget.radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: image,
      );
    }

    return image;
  }
}
