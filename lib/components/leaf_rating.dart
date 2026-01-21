import 'package:flutter/material.dart';
import 'package:nyc_parks/styles/styles.dart';

/// A leaf-based rating display that fills leaves with green based on rating.
/// Rating is expected to be 1-10, displayed as 5 leaves (each leaf = 2 points).
class LeafRating extends StatelessWidget {
  final int? rating;
  final double size;
  final bool showValue;

  const LeafRating({
    super.key,
    required this.rating,
    this.size = 24,
    this.showValue = true,
  });

  // Styling aided by Cursor and Opus 4.5 AI
  @override
  Widget build(BuildContext context) {
    final displayRating = rating ?? 0;
    final normalizedRating = (displayRating / 2).clamp(0.0, 5.0);
    final normalizedRatingRounded = normalizedRating.toStringAsFixed(1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final fillAmount = (normalizedRating - index).clamp(0.0, 1.0);
          return _LeafIcon(
            fillAmount: fillAmount,
            size: size,
          );
        }),
        if (showValue && rating != null) ...[
          const SizedBox(width: 8),
          Text(
            normalizedRatingRounded, // Rounded rating halved for display
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '/5',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LeafIcon extends StatelessWidget {
  final double fillAmount;
  final double size;

  const _LeafIcon({
    required this.fillAmount,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Empty leaf (outline)
          CustomPaint(
            size: Size(size, size),
            painter: _LeafPainter(
              fillAmount: 0,
              fillColor: AppColors.primaryLight.withValues(alpha: 0.2),
              strokeColor: AppColors.primaryLight.withValues(alpha: 0.4),
            ),
          ),
          // Filled portion
          ClipRect(
            clipper: _FillClipper(fillAmount),
            child: CustomPaint(
              size: Size(size, size),
              painter: _LeafPainter(
                fillAmount: 1,
                fillColor: AppColors.primary,
                strokeColor: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillClipper extends CustomClipper<Rect> {
  final double fillAmount;

  _FillClipper(this.fillAmount);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillAmount, size.height);
  }

  @override
  bool shouldReclip(_FillClipper oldClipper) => fillAmount != oldClipper.fillAmount;
}

class _LeafPainter extends CustomPainter {
  final double fillAmount;
  final Color fillColor;
  final Color strokeColor;

  _LeafPainter({
    required this.fillAmount,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = _createLeafPath(size);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    // Draw center vein
    final veinPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final veinPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.5,
        size.height * 0.15,
      );

    canvas.drawPath(veinPath, veinPaint);
  }

  Path _createLeafPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at bottom (stem)
    path.moveTo(w * 0.5, h * 0.95);

    // Left side curve
    path.quadraticBezierTo(
      w * 0.1, h * 0.7,
      w * 0.15, h * 0.4,
    );
    path.quadraticBezierTo(
      w * 0.2, h * 0.15,
      w * 0.5, h * 0.05,
    );

    // Right side curve
    path.quadraticBezierTo(
      w * 0.8, h * 0.15,
      w * 0.85, h * 0.4,
    );
    path.quadraticBezierTo(
      w * 0.9, h * 0.7,
      w * 0.5, h * 0.95,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_LeafPainter oldDelegate) =>
      fillAmount != oldDelegate.fillAmount ||
      fillColor != oldDelegate.fillColor;
}

/// Compact leaf rating for use in review cards
class LeafRatingCompact extends StatelessWidget {
  final int rating;
  final double size;

  const LeafRatingCompact({
    super.key,
    required this.rating,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LeafPainter(
            fillAmount: 1,
            fillColor: AppColors.primary,
            strokeColor: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$rating',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

