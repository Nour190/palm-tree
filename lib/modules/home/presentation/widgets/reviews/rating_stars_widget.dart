import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';

class RatingStarsWidget extends StatelessWidget {
  const RatingStarsWidget({
    super.key,
    required this.rating,
  });

  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final frac = rating - full;
    final hasHalf = frac >= 0.25 && frac < 0.75;
    const total = 5;

    final stars = List<Widget>.generate(total, (i) {
      IconData icon;
      if (i < full) {
        icon = Icons.star;
      } else if (i == full && hasHalf) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, size: 18.sSp, color: Colors.amber);
    });

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
