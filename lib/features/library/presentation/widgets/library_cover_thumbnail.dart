import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../media/data/media_repository.dart';

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

    return FutureBuilder<File?>(
      future: _resolveExistingFile(ref, path),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return _placeholder(context);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(context),
          ),
        );
      },
    );
  }

  Future<File?> _resolveExistingFile(WidgetRef ref, String path) async {
    try {
      final file = await ref
          .watch(mediaRepositoryProvider)
          .resolveLocalFile(path);
      return await file.exists() ? file : null;
    } on FileSystemException {
      return null;
    }
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
