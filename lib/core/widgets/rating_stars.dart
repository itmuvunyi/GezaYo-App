import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= rating;
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starNumber)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: AppColors.accentOrange,
              size: iconSize,
            ),
          ),
        );
      }),
    );
  }
}
