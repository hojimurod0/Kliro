import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(
          Icons.image,
          color: Colors.grey[600],
        ),
      );
    }

    // Calculate memory cache dimensions for optimization
    // If width/height provided, use them; otherwise use reasonable defaults
    // Check for finite values to avoid Infinity/NaN errors
    final int? memCacheWidth = width != null && width! > 0 && width!.isFinite
        ? (width! * 2).toInt() // 2x for high DPI screens
        : null;
    final int? memCacheHeight =
        height != null && height! > 0 && height!.isFinite
            ? (height! * 2).toInt() // 2x for high DPI screens
            : null;

    final child = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // debugPrint('⚠️ Image load error: $url -> $error');
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[600],
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
