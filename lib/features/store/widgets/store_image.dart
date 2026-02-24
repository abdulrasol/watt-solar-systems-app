import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isCircle;
  final Color? backgroundColor;
  final Widget? fallback;

  const StoreImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.isCircle = false,
    this.backgroundColor,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // Valid URL Check: Not null, not empty, and not a local file URI (unless we supported file, but NetworkImage crashes on file://)
    bool isValidUrl = false;
    if (url != null && url!.isNotEmpty) {
      try {
        final uri = Uri.parse(url!);
        if (uri.hasScheme && uri.scheme.startsWith('http')) {
          isValidUrl = true;
        }
      } catch (e) {
        // invalid uri
      }
    }

    Widget imageWidget;

    if (isValidUrl) {
      imageWidget = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (context, url, error) => _buildPlaceholder(),
        placeholder: (context, url) => _buildPlaceholder(isLoading: true),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    if (isCircle) {
      return ClipOval(child: imageWidget);
    } else if (borderRadius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    // Use user provided size or fallback to size from constraints if possible, but simplest is Container
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]))
            : fallback ??
                  Icon(
                    Icons.solar_power, // Keeping standardized placeholder
                    color: Colors.grey[400],
                    size: (height != null && height! < 50) ? 20 : 32,
                  ),
      ),
    );
  }
}
