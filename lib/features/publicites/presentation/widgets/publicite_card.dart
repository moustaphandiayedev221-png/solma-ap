import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../../data/publicite_model.dart';

/// Carte pour une publicité — affiche uniquement l'image.
class PubliciteCard extends StatelessWidget {
  const PubliciteCard({super.key, required this.publicite});

  final PubliciteModel publicite;

  Future<void> _onTap(BuildContext context) async {
    if (publicite.productId != null && publicite.productId!.isNotEmpty) {
      context.push('${AppRoutes.product}/${publicite.productId}');
    } else if (publicite.linkUrl != null && publicite.linkUrl!.isNotEmpty) {
      final url = publicite.linkUrl!;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else if (url.startsWith('/')) {
        context.push(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final hasTap =
        (publicite.productId != null && publicite.productId!.isNotEmpty) ||
            (publicite.linkUrl != null && publicite.linkUrl!.trim().isNotEmpty);

    return GestureDetector(
      onTap: hasTap ? () => _onTap(context) : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(r.horizontalPadding, 8, r.horizontalPadding, 6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card(context),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: publicite.imageUrl.isNotEmpty
                ? ImageOptimizer.optimizedNetworkImage(
                    imageUrl: publicite.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
