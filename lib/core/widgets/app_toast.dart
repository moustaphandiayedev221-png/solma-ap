import 'package:flutter/material.dart';

/// Toast animé affiché en haut à droite, responsive et fluide.
class AppToast {
  AppToast._();

  static const Duration _durationIn = Duration(milliseconds: 400);
  static const Duration _durationOut = Duration(milliseconds: 350);
  static const Duration _displayDuration = Duration(seconds: 3);
  static const Curve _curveIn = Curves.easeOutCubic;
  static const Curve _curveOut = Curves.easeInCubic;

  /// Affiche un toast en haut à droite.
  /// [context] : contexte pour l'overlay
  /// [message] : texte à afficher
  /// [isError] : true pour un style erreur (fond rouge)
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWrapper(
        message: message,
        isError: isError,
        theme: theme,
        mediaQuery: mediaQuery,
        onDismiss: () {
          entry.remove();
        },
        durationIn: _durationIn,
        durationOut: _durationOut,
        displayDuration: _displayDuration,
        curveIn: _curveIn,
        curveOut: _curveOut,
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWrapper extends StatefulWidget {
  const _ToastWrapper({
    required this.message,
    required this.isError,
    required this.theme,
    required this.mediaQuery,
    required this.onDismiss,
    required this.durationIn,
    required this.durationOut,
    required this.displayDuration,
    required this.curveIn,
    required this.curveOut,
  });

  final String message;
  final bool isError;
  final ThemeData theme;
  final MediaQueryData mediaQuery;
  final VoidCallback onDismiss;
  final Duration durationIn;
  final Duration durationOut;
  final Duration displayDuration;
  final Curve curveIn;
  final Curve curveOut;

  @override
  State<_ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<_ToastWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.durationIn,
    );

    _slideAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curveIn),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curveIn),
    );

    _controller.forward();

    Future.delayed(widget.displayDuration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = widget.mediaQuery.padding.top;
    final screenWidth = widget.mediaQuery.size.width;
    final maxWidth = (screenWidth * 0.85).clamp(200.0, 400.0);

    return Positioned(
      top: safeTop + 12,
      right: 16,
      child: SizedBox(
        width: maxWidth,
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(150 * _slideAnimation.value, 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                color: widget.isError
                    ? widget.theme.colorScheme.errorContainer
                    : widget.theme.colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isError ? Icons.error_outline : Icons.info_outline,
                      size: 22,
                      color: widget.isError
                          ? widget.theme.colorScheme.onErrorContainer
                          : widget.theme.colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isError
                              ? widget.theme.colorScheme.onErrorContainer
                              : widget.theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
