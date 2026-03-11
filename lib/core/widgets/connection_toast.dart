import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'app_loader.dart';
import '../theme/app_shadows.dart';

/// Toast personnalisé en haut à droite — style grandes applications.
/// Affiche loader + icône + message d'erreur de connexion.
class ConnectionToast extends StatelessWidget {
  const ConnectionToast({
    super.key,
    required this.message,
    this.showLoader = true,
    this.onRetry,
  });

  final String message;
  final bool showLoader;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: topPadding + 12,
      right: 16,
      child: SafeArea(
        top: false,
        child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.card(context),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showLoader) ...[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: AppLoader(
                          size: 22,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Icon(
                        LucideIcons.wifiOff,
                        size: 22,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRetry,
                        icon: Icon(
                          LucideIcons.refreshCw,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
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
