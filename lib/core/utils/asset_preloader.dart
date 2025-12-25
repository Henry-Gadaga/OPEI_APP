import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Utility to warm up frequently used assets to avoid first-use jank on web.
class AssetPreloader {
  /// Pre-cache a list of SVG asset paths.
  static Future<void> warmUpSvgList(BuildContext context, List<String> assets) async {
    // Ensure a stable picture cache size for web; default is fine but we keep it explicit.
    final futures = <Future<void>>[];
    for (final asset in assets) {
      if (asset.isEmpty) continue;
      try {
        final loader = SvgAssetLoader(asset);
        futures.add(svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        ).then((_) {}));
      } catch (e) {
        debugPrint('⚠️ SVG warm-up failed for $asset: $e');
      }
    }
    await Future.wait(futures, eagerError: false);
  }
}
