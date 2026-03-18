/// A high-performance Flutter widget for loading and caching network images.
///
/// ## ✨ Features
/// - Memory and disk caching support
/// - Progressive image rendering (preview → full image)
/// - Custom placeholder and error widgets
/// - Smooth fade animation between states
/// - Optional rounded corners
/// - Image resizing for performance optimization
///
/// ## 🧠 Behavior
/// - Displays a placeholder while loading
/// - Shows a preview image first
/// - Replaces it with a fully decoded image
/// - Handles errors gracefully
///
/// ## 📦 Example
/// ```dart
/// AdvancedCacheNetworkImage(
///   url: "https://example.com/image.jpg",
///   height: 200,
///   fit: BoxFit.cover,
///   radius: 12,
///   enableFade: true,
/// )
/// ```
library;

import 'dart:typed_data';
import 'dart:ui';
import 'package:advanced_cache_network_image/advanced_cache_network_image.dart';
import 'package:flutter/material.dart';
import 'image_loader.dart';

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
  final double radius;

  /// Target width for decoding the image.
  final int? targetWidth;

  /// Target height for decoding the image.
  final int? targetHeight;

  /// Duration for which the image is cached.
  final Duration? cacheDuration;

  /// Whether to use in-memory caching.
  final bool useMemoryCache;

  /// Whether to use disk caching.
  final bool useDiskCache;

  /// Whether to animate between placeholder and image.
  ///
  /// Defaults to `true`.
  final bool enableFade;

  /// Duration of fade animation.
  ///
  /// Defaults to 300 milliseconds.
  final Duration fadeDuration;

  /// Builder for rendering the final image.
  ///
  /// Gives full control over how the image is displayed.
  final Widget Function(BuildContext context, ImageProvider image)?
      imageBuilder;

  /// Builder for loading progress.
  ///
  /// Provides download progress (0.0 → 1.0).
  final Widget Function(BuildContext context, double progress)? progressBuilder;

  /// Optional custom loader for advanced cache/network control.
  ///
  /// If not provided, [ImageLoader.shared] is used.
  final ImageLoader? imageLoader;

  /// Optional cancel token for aborting in-flight requests.
  final CancelToken? cancelToken;

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
    this.enableFade = true,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.imageBuilder,
    this.progressBuilder,
    this.imageLoader,
    this.cancelToken,
  });

  @override
  State<AdvancedCacheNetworkImage> createState() =>
      _AdvancedCacheNetworkImageState();
}

class _AdvancedCacheNetworkImageState extends State<AdvancedCacheNetworkImage> {
  double progress = 0.0;
  bool isError = false;
  Uint8List? bytes;
  ImageProvider? previewImage;
  ImageProvider? fullImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final loader = widget.imageLoader ?? ImageLoader.shared;
      bytes = await loader.loadBytes(
        widget.url,
        useMemoryCache: widget.useMemoryCache,
        useDiskCache: widget.useDiskCache,
        cacheDuration: widget.cacheDuration,
        cancelToken: widget.cancelToken,
        onProgress: (received, total) {
          if (total != null && total > 0) {
            progress = received / total;
          } else {
            progress = 0;
          }

          if (mounted) setState(() {});
        },
      );

      /// Preview
      previewImage = MemoryImage(bytes!);

      if (!mounted) return;
      setState(() {});

      /// Full decode
      final codec = await instantiateImageCodec(
        bytes!,
        targetWidth: widget.targetWidth,
        targetHeight: widget.targetHeight,
      );
      await codec.getNextFrame();

      fullImage = MemoryImage(bytes!);

      if (!mounted) return;
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    /// 🔴 Error state
    if (isError) {
      content = widget.errorWidget ?? const Center(child: Icon(Icons.error));
    }

    /// ⏳ Loading state (with progress)
    else if (bytes == null) {
      if (widget.progressBuilder != null) {
        content = widget.progressBuilder!(context, progress);
      } else {
        content = widget.placeholder ??
            const Center(child: CircularProgressIndicator());
      }
    }

    /// 🖼 Image state
    else {
      final provider = fullImage ?? previewImage!;

      if (widget.imageBuilder != null) {
        content = widget.imageBuilder!(context, provider);
      } else {
        content = Image(
          key: ValueKey(provider),
          image: provider,
          fit: widget.fit,
        );
      }
    }

    /// 📏 Size
    if (widget.width != null || widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }

    /// 🔵 Radius
    if (widget.radius > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: content,
      );
    }

    /// ✨ Fade
    if (widget.enableFade) {
      content = AnimatedSwitcher(
        duration: widget.fadeDuration,
        child: content,
      );
    }

    return content;
  }
}
