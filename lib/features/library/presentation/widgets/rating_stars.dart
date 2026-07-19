import 'package:flutter/material.dart';

import '../../domain/rating.dart';

/// Read-only star representation of the library-level personal rating.
class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.emptyLabel = '-',
    this.maxLines = 1,
    super.key,
  });

  final int? rating;
  final String emptyLabel;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final value = formatStarRating(rating);
    return Text(
      value == '-' ? emptyLabel : value,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
