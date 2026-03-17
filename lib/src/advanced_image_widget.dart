import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'image_loader.dart';

class AdvancedCacheNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit? fit;

  final Widget? placeholder;
  final Widget? errorWidget;

  final double? width;
  final double? height;

  final double radius;

  final int? targetWidth;
  final int? targetHeight;

  final Duration? cacheDuration;

  final bool useMemoryCache;
  final bool useDiskCache;

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

class _AdvancedCacheNetworkImageState extends State<AdvancedCacheNetworkImage> {
  final loader = ImageLoader();

  File? file;
  bool isError = false;
  Uint8List? bytes;
  ImageProvider? previewImage;
  ImageProvider? fullImage;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      bytes = await loader.loadBytes(widget.url);

      /// 1️⃣ Decode small preview

      previewImage = MemoryImage(bytes!);

      if (!mounted) return;

      setState(() {});

      /// 2️⃣ Decode full image
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
