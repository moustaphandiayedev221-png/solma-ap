import 'package:flutter/material.dart';

/// Détecte le geste swipe depuis le bord gauche pour fermer (style iOS).
/// À placer autour du contenu d'une page pour activer le retour par geste.
class SwipeBackDetector extends StatefulWidget {
  const SwipeBackDetector({
    super.key,
    required this.child,
    this.onSwipeBack,
    this.edgeWidth = 24,
    this.minDragDistance = 80,
  });

  final Widget child;
  final VoidCallback? onSwipeBack;
  final double edgeWidth;
  final double minDragDistance;

  @override
  State<SwipeBackDetector> createState() => _SwipeBackDetectorState();
}

class _SwipeBackDetectorState extends State<SwipeBackDetector> {
  double _dragExtent = 0;

  void _onHorizontalDragStart(DragStartDetails details) {
    if (details.localPosition.dx <= widget.edgeWidth) {
      setState(() => _dragExtent = 0);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 && _dragExtent >= 0) {
      setState(() => _dragExtent += details.delta.dx);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent >= widget.minDragDistance ||
        (details.velocity.pixelsPerSecond.dx > 300 && _dragExtent > 20)) {
      if (widget.onSwipeBack != null) {
        widget.onSwipeBack!();
      } else {
        _defaultPop();
      }
    }
    setState(() => _dragExtent = 0);
  }

  void _defaultPop() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
