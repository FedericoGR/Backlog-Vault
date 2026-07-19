import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../media/application/media_providers.dart';

/// Displays bounded local cover bytes with a non-sensitive visual fallback.
class LibraryCoverThumbnail extends ConsumerWidget {
  const LibraryCoverThumbnail({
    required this.localPath,
    required this.width,
    required this.height,
    this.borderRadius = 6,
    super.key,
  });

  final String? localPath;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = localPath;
    if (path == null || path.trim().isEmpty) {
      return _placeholder(context);
    }

    final bytes = ref.watch(localMediaBytesProvider(path));
    return bytes.when(
      data: (value) {
        if (value == null) return _placeholder(context);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            value,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(context),
          ),
        );
      },
      loading: () => _placeholder(context),
      error: (_, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final iconSize = width.isFinite ? width * 0.42 : 42.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.image_outlined,
        size: iconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
