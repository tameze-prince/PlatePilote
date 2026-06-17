import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Network image with disk + memory cache, graceful error fallback.
///
/// Defaults are tuned for low/mid-tier Android devices:
/// - disk cache clamped to 1000 px on the longest edge
/// - memory cache clamped to 800 px on the longest edge
/// - error falls back to a placeholder asset rather than a broken icon
class PpImage {
  const PpImage._();

  static const String defaultRecipePlaceholder =
      'assets/images/placeholders/recipe_placeholder.webp';
  static const String defaultPantryPlaceholder =
      'assets/images/placeholders/pantry_placeholder.webp';
  static const String defaultEmptyIllustration =
      'assets/images/placeholders/illustration_empty.webp';

  static Widget network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String placeholder = defaultRecipePlaceholder,
    int memCacheWidth = 800,
    int memCacheHeight = 800,
    int maxWidthDiskCache = 1000,
  }) {
    return CachedNetworkImage(
      key: key,
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      placeholder: (_, _) => _Placeholder(placeholder, width: width, height: height, fit: fit),
      errorWidget: (_, _, _) => _Placeholder(placeholder, width: width, height: height, fit: fit),
    );
  }

  static Widget asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) {
        return _Placeholder(
          defaultRecipePlaceholder,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  /// Compress a raw file (post-pick) down to <= 1080 px / ~250 KB.
  /// Returns null if compression fails — the caller falls back to the
  /// original file path.
  static Future<XFile?> compress(XFile source, {int quality = 80, int maxWidth = 1080}) {
    return FlutterImageCompress.compressAndGetFile(
      source.path,
      '${source.path}_pp.jpg',
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxWidth,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.path, {this.width, this.height, required this.fit});

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );
  }
}
