/// Transitions de page professionnelles — style Amazon, Zara, Airbnb.
///
/// - Fade + slide léger pour écrans modaux
/// - Slide horizontal pour détails (style iOS sur mobile)
/// - Durées optimisées pour une UX fluide
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transition par défaut : fade + léger slide vers le haut.
/// Utilisée pour : onboarding, login, signup, settings.
CustomTransitionPage<void> buildFadeSlideTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
  Curve curve = Curves.easeOutCubic,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: curve,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Transition slide horizontal (style iOS) — pour ProductDetail, Checkout, etc.
/// Sur iOS natif, utilise une courbe plus "bouncy" pour un rendu premium.
CustomTransitionPage<void> buildSlideTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 400),
}) {
  final isIOS = !kIsWeb && Platform.isIOS;
  final curve = isIOS ? Curves.easeInOutCubic : Curves.easeOutCubic;

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: curve,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
