import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Read-only presentation of the single personal rating.
class PersonalRatingStars extends StatelessWidget {
  const PersonalRatingStars({required this.rating, this.size = 16, super.key});
  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.ratingStars(rating),
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rating; i++)
            Icon(
              Icons.star,
              size: size,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    ),
  );
}
