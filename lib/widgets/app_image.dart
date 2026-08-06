import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays an image from a local path.
///
/// On native platforms this reads the file straight off disk.
/// On Flutter Web, [Image.file] is not supported and image_picker /
/// the browser's camera capture return `blob:` URLs instead of real
/// file paths — so on web we load the same path through
/// [Image.network], which Flutter Web resolves via the browser's
/// fetch/XHR stack and happily accepts `blob:` URLs.
class AppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? errorBuilder;

  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorBuilder != null
        ? (BuildContext c, Object e, StackTrace? s) => errorBuilder!(c)
        : (BuildContext c, Object e, StackTrace? s) => Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.image_not_supported_rounded)),
            );

    if (kIsWeb) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: fallback,
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: fallback,
    );
  }
}
