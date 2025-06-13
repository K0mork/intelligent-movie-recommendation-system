import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final bool allowHalfRating;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24.0,
    this.color,
    this.unratedColor,
    this.allowHalfRating = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    final inactiveColor = unratedColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            _getStarIcon(index + 1, rating),
            color: _getStarColor(index + 1, rating, activeColor, inactiveColor),
            size: size,
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int position, double rating) {
    if (rating >= position) {
      return Icons.star;
    } else if (allowHalfRating && rating >= position - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(
    int position,
    double rating,
    Color activeColor,
    Color inactiveColor,
  ) {
    if (rating >= position) {
      return activeColor;
    } else if (allowHalfRating && rating >= position - 0.5) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final Color? color;
  final Color? unratedColor;
  final ValueChanged<double> onRatingChanged;

  const InteractiveStarRating({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    this.maxRating = 5,
    this.size = 32.0,
    this.color,
    this.unratedColor,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.color ?? theme.colorScheme.primary;
    final inactiveColor = widget.unratedColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              _currentRating > index ? Icons.star : Icons.star_border,
              color: _currentRating > index ? activeColor : inactiveColor,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}