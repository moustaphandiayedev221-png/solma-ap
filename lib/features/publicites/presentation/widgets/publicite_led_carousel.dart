import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../../data/publicite_model.dart';

/// Carrousel LED : affiche les publicités en défilement automatique (même rythme que les bannières : 5 s).
class PubliciteLedCarousel extends ConsumerStatefulWidget {
  const PubliciteLedCarousel({super.key, required this.publicites});

  final List<PubliciteModel> publicites;

  @override
  ConsumerState<PubliciteLedCarousel> createState() => _PubliciteLedCarouselState();
}

class _PubliciteLedCarouselState extends ConsumerState<PubliciteLedCarousel> {
  late PageController _pageController;
  late Timer _timer;
  static const _interval = Duration(seconds: 5);
  static const _slideDur = Duration(milliseconds: 850);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(_interval, (_) => _nextSlide());
  }

  void _nextSlide() {
    if (!mounted || widget.publicites.length <= 1) return;
    final next = (_pageController.page?.round() ?? 0) + 1;
    final target = next >= widget.publicites.length ? 0 : next;
    _pageController.animateToPage(
      target,
      duration: _slideDur,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    if (widget.publicites.isEmpty) return const SizedBox.shrink();

    const cardHeight = 80.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(r.horizontalPadding, 8, r.horizontalPadding, 6),
      child: SizedBox(
        height: cardHeight,
        child: Container(
          decoration: _ledContainerDecoration(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: widget.publicites.length == 1
                ? _LedCardContent(publicite: widget.publicites.first)
                : PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.publicites.length,
                    itemBuilder: (_, index) => _LedCardContent(
                      publicite: widget.publicites[index],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  static BoxDecoration _ledContainerDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? theme.colorScheme.outline.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.9),
        width: 2,
      ),
      boxShadow: AppShadows.card(context),
    );
  }
}

class _LedCardContent extends StatelessWidget {
  const _LedCardContent({
    required this.publicite,
  });

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
    final hasTap =
        (publicite.productId != null && publicite.productId!.isNotEmpty) ||
            (publicite.linkUrl != null && publicite.linkUrl!.trim().isNotEmpty);

    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: hasTap ? () => _onTap(context) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          publicite.imageUrl.isNotEmpty
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
          if (isDark)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
        ],
      ),
    );
  }
}
