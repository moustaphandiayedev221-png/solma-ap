import 'package:flutter/material.dart';

import 'app_loader.dart';
import '../theme/app_theme.dart';

/// Bouton noir arrondi premium (style Nike)
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null && !isLoading,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            shadowColor: Colors.black.withValues(alpha: 0.1),
          ),
          child: isLoading
              ? AppButtonLoader(
                  size: 24,
                  color: theme.colorScheme.onPrimary,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(label, style: AppTheme.textStyle(16, FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}
