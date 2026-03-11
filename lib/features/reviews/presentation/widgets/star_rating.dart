import 'package:flutter/material.dart';

/// Widget d'étoiles — mode lecture (affichage) ou sélection (interactif).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24,
    this.color,
    this.spacing = 2,
  });

  /// Note actuelle (0-5, supporte les demi-étoiles en lecture).
  final double rating;

  /// Callback quand l'utilisateur sélectionne une note (null = mode lecture).
  final ValueChanged<int>? onRatingChanged;

  /// Taille des icônes.
  final double size;

  /// Couleur des étoiles (par défaut : amber).
  final Color? color;

  /// Espacement entre les étoiles.
  final double spacing;

  bool get _isInteractive => onRatingChanged != null;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        IconData icon;

        if (rating >= starIndex) {
          icon = Icons.star_rounded;
        } else if (rating >= starIndex - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        final star = Icon(
          icon,
          size: size,
          color: rating >= starIndex - 0.5 ? starColor : Colors.grey.shade300,
        );

        if (_isInteractive) {
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: GestureDetector(
              onTap: () => onRatingChanged!(starIndex),
              child: star,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: star,
        );
      }),
    );
  }
}
