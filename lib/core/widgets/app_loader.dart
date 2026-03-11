import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Loader centralisé professionnel — utilisé sur toutes les pages.
/// Design inspiré des grandes applications (Apple, Stripe, Linear).
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth,
  });

  /// Taille du loader (diamètre).
  final double size;

  /// Couleur du loader (défaut: primary du thème).
  final Color? color;

  /// Épaisseur du trait (défaut: ~12% de size).
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    final stroke = strokeWidth ?? (size * 0.12).clamp(2.0, 4.0);

    return SizedBox(
      width: size,
      height: size,
      child: _AppLoaderPainter(
        color: c,
        strokeWidth: stroke,
        size: size,
      ),
    );
  }
}

/// Loader full-page — centré, avec message optionnel.
class AppPageLoader extends StatelessWidget {
  const AppPageLoader({
    super.key,
    this.message,
    this.minHeight = 200,
  });

  /// Message optionnel sous le loader (ex. "Chargement…").
  final String? message;

  /// Hauteur minimale pour éviter les sauts de layout.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader(size: 36),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loader compact pour sections (grilles, listes) — garde le même design.
class AppSectionLoader extends StatelessWidget {
  const AppSectionLoader({
    super.key,
    this.minHeight = 120,
  });

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: const AppLoader(size: 28),
      ),
    );
  }
}

/// Loader pour boutons — petit, discret.
class AppButtonLoader extends StatelessWidget {
  const AppButtonLoader({
    super.key,
    this.size = 20,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppLoader(size: size, color: color);
  }
}

/// Peintre du loader — arc rotatif élégant (style iOS / Linear).
class _AppLoaderPainter extends StatefulWidget {
  const _AppLoaderPainter({
    required this.color,
    required this.strokeWidth,
    required this.size,
  });

  final Color color;
  final double strokeWidth;
  final double size;

  @override
  State<_AppLoaderPainter> createState() => _AppLoaderPainterState();
}

class _AppLoaderPainterState extends State<_AppLoaderPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LoaderArcPainter(
            progress: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _LoaderArcPainter extends CustomPainter {
  _LoaderArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(r, r), radius: r - strokeWidth / 2);

    // Arc de 75° qui tourne, avec dégradé de transparence à la queue
    const sweepAngle = 75 * math.pi / 180;
    final startAngle = -math.pi / 2 + (progress * 2 * math.pi);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LoaderArcPainter old) =>
      old.progress != progress || old.color != color;
}
