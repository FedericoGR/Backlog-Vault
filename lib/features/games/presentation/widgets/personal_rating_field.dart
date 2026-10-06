import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// Edits the sole personal rating; null means the game has not been rated.
class PersonalRatingField extends StatelessWidget {
  const PersonalRatingField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.gameRating,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var rating = 1; rating <= 5; rating++)
              Semantics(
                selected: value == rating,
                child: IconButton(
                  key: ValueKey('rating-$rating'),
                  tooltip:
                      rating == 1
                          ? context.l10n.ratingOneStar
                          : context.l10n.ratingStars(rating),
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icon(
                    rating <= (value ?? 0) ? Icons.star : Icons.star_border,
                  ),
                  onPressed: () => onChanged(rating),
                ),
              ),
            if (value != null)
              TextButton(
                key: const ValueKey('clear-rating'),
                onPressed: () => onChanged(null),
                child: Text(context.l10n.clear),
              ),
          ],
        ),
      ],
    );
  }
}
