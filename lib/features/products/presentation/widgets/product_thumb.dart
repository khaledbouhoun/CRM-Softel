import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Square product image (or a clean placeholder when there is none / it
/// cannot be displayed, e.g. an SVG or an unreachable URL).
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, this.url, this.size = 40, this.fit});

  final String? url;
  final double size;
  final BoxFit? fit;

  bool get _hasUrl => url != null && url!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size > 60 ? 12 : 8);
    final placeholder = Icon(
      Icons.inventory_2_outlined,
      size: size * 0.5,
      color: context.colors.outline,
    );
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      alignment: Alignment.center,
      child: _hasUrl
          ? Image.network(
              url!.trim(),
              width: size,
              height: size,
              fit: fit ?? BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            )
          : placeholder,
    );
  }
}
