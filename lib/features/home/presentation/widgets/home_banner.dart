import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/image_optimizer.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../data/banner_model.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  CAROUSEL
// ═════════════════════════════════════════════════════════════════════════════

class HomeBanner extends StatefulWidget {
  const HomeBanner({required this.banners, super.key});

  final List<BannerModel> banners;

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with SingleTickerProviderStateMixin {
  late final PageController _page;
  late final AnimationController _progress;
  int _current = 0;
  double _offset = 0;

  static const _interval = Duration(seconds: 5);
  static const _slideDur = Duration(milliseconds: 850);

  @override
  void initState() {
    super.initState();
    _page = PageController(viewportFraction: 0.88)..addListener(_sync);
    _progress = AnimationController(vsync: this, duration: _interval)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      })
      ..forward();
  }

  @override
  void dispose() {
    _page
      ..removeListener(_sync)
      ..dispose();
    _progress.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted || _page.page == null) return;
    setState(() => _offset = _page.page!);
  }

  void _next() {
    if (!mounted) return;
    final len = widget.banners.length;
    if (len == 0) return;
    _current = (_current + 1) % len;
    _page.animateToPage(
      _current,
      duration: _slideDur,
      curve: Curves.easeInOutCubic,
    );
    _progress.forward(from: 0);
  }

  void _onChanged(int i) {
    if (!mounted) return;
    setState(() => _current = i);
    _progress.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.responsive;
    final isDark = theme.brightness == Brightness.dark;
    final list = widget.banners;
    final bannerHeight = r.isCompactSmall ? 160.0 : 196.0;

    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _page,
            onPageChanged: _onChanged,
            itemCount: list.length,
            padEnds: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: _Slide(
                data: list[i],
                isDark: isDark,
                diff: i - _offset,
                active: i == _current,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _Indicator(
          count: list.length,
          current: _current,
          progress: _progress,
          theme: theme,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  INDICATOR
// ═════════════════════════════════════════════════════════════════════════════

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.count,
    required this.current,
    required this.progress,
    required this.theme,
  });

  final int count;
  final int current;
  final AnimationController progress;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 4,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: active
                ? Colors.transparent
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          child: active
              ? AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.25,
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SINGLE SLIDE  —  all the magic happens here
// ═════════════════════════════════════════════════════════════════════════════

class _Slide extends StatefulWidget {
  const _Slide({
    required this.data,
    required this.isDark,
    required this.diff,
    required this.active,
  });

  final BannerModel data;
  final bool isDark;
  final double diff;
  final bool active;

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> with TickerProviderStateMixin {
  // ── Main stagger controller (entrance) ──
  late final AnimationController _enter;

  // ── Continuous floating for the shoe ──
  late final AnimationController _float;

  // ── Shimmer sweep on the gradient side ──
  late final AnimationController _shimmer;

  // ── CTA subtle pulse ──
  late final AnimationController _pulse;

  // Entrance intervals
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _accentFade;
  late final Animation<double> _accentScale;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;
  late final Animation<double> _shoeFade;
  late final Animation<Offset> _shoeSlide;
  late final Animation<double> _shoeScale;
  late final Animation<double> _bgFade;
  late final Animation<double> _decoFade;

  @override
  void initState() {
    super.initState();

    // ── Entrance (stagger) ──
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleFade = _curved(0.0, 0.35);
    _titleSlide = _offsetAnim(
      const Offset(-0.25, 0.0),
      0.0,
      0.35,
      Curves.easeOutCubic,
    );
    _subtitleFade = _curved(0.08, 0.42);
    _subtitleSlide = _offsetAnim(
      const Offset(-0.20, 0.0),
      0.08,
      0.42,
      Curves.easeOutCubic,
    );
    _accentFade = _curved(0.18, 0.55);
    _accentScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.18, 0.55, curve: Curves.elasticOut),
      ),
    );
    _ctaFade = _curved(0.35, 0.7);
    _ctaSlide = _offsetAnim(
      const Offset(0, 0.5),
      0.35,
      0.7,
      Curves.easeOutCubic,
    );
    _shoeFade = _curved(0.0, 0.5);
    _shoeSlide = _offsetAnim(
      const Offset(0.4, -0.1),
      0.0,
      0.5,
      Curves.easeOutCubic,
    );
    _shoeScale = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _bgFade = _curved(0.0, 0.3);
    _decoFade = _curved(0.3, 0.75);

    // ── Floating (continuous) ──
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // ── Shimmer sweep ──
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // ── CTA pulse ──
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    if (widget.active) _enter.forward();
  }

  Animation<double> _curved(double begin, double end) {
    return Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enter,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _offsetAnim(
    Offset from,
    double begin,
    double end,
    Curve curve,
  ) {
    return Tween(begin: from, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _enter,
        curve: Interval(begin, end, curve: curve),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _Slide old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _enter.forward(from: 0);
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    _shimmer.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ── Parallax helpers ──
  double get _absOff => widget.diff.abs().clamp(0.0, 1.0);
  double get _scale => 1.0 - (_absOff * 0.06);
  double get _yShift => _absOff * 8.0;
  double get _shoeParallax => widget.diff * -35.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = widget.data;
    final isDark = widget.isDark;

    return Transform.translate(
      offset: Offset(0, _yShift),
      child: Transform.scale(
        scale: _scale,
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, _float, _shimmer, _pulse]),
          builder: (context, _) {
            final floatVal = math.sin(_float.value * math.pi) * 4.0;
            final shimmerVal = _shimmer.value;
            final pulseVal = 0.85 + (_pulse.value * 0.15);

            return _card(
              context,
              cs,
              d,
              isDark,
              floatVal,
              shimmerVal,
              pulseVal,
            );
          },
        ),
      ),
    );
  }

  /// Résout l'URL de destination : linkUrl prioritaire, sinon subtitle si chemin, sinon inféré depuis le titre.
  /// Les URLs externes (https) sont retournées telles quelles pour url_launcher.
  static String _resolveTargetUrl(BannerModel d) {
    var url = d.linkUrl?.trim();
    if ((url == null || url.isEmpty) && (d.subtitle?.trim() ?? '').startsWith('/')) {
      url = d.subtitle!.trim();
    }
    // URL externe : retourner null pour traitement séparé
    if (url != null && url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return url;
    }
    if (url != null && url.isNotEmpty) {
      var path = url.startsWith('/') ? url : '/$url';
      // /products?category=men -> /products/category/men (évite "Page non trouvée")
      final uri = Uri.tryParse(path);
      if (uri != null && uri.path == '/products') {
        final cat = uri.queryParameters['category'];
        if (cat != null && cat.isNotEmpty) {
          return '${AppRoutes.productsCategory}/$cat';
        }
      }
      // Normaliser les raccourcis (ex: "new", "popular" depuis l'admin)
      final lower = path.toLowerCase().split('?').first;
      if (lower == '/new' || lower == 'new') return '${AppRoutes.productsSection}/new';
      if (lower == '/popular' || lower == 'popular') return '${AppRoutes.productsSection}/popular';
      if (lower == '/sports' || lower == 'sports') return '${AppRoutes.productsSection}/sports';
      return path;
    }
    final t = d.title.toLowerCase();
    if (t.contains('livraison') || t.contains('shipping')) {
      return AppRoutes.helpCenter;
    }
    if (t.contains('meilleure') || t.contains('best sale') || t.contains('réduction') || t.contains('discount')) {
      return '${AppRoutes.productsSection}/popular';
    }
    if (t.contains('nouvelle') || t.contains('new collection') || t.contains('exclusivité') || t.contains('exclusive') || t.contains('édition limitée')) {
      return '${AppRoutes.productsSection}/new';
    }
    return '${AppRoutes.productsSection}/new';
  }

  Future<void> _onBannerTap() async {
    final target = _resolveTargetUrl(widget.data);
    if (target.isEmpty) return;
    if (target.startsWith('http://') || target.startsWith('https://')) {
      final uri = Uri.tryParse(target);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      if (context.mounted) context.push(target);
    }
  }

  Widget _card(
    BuildContext context,
    ColorScheme cs,
    BannerModel d,
    bool isDark,
    double floatY,
    double shimmerT,
    double pulseScale,
  ) {
    final title = d.title;
    final subtitle = d.subtitle ?? '';
    final accentPre = d.accentText ?? '';
    final accentValue = d.accentValue ?? '';
    final l10n = AppLocalizations.of(context)!;
    final cta = (d.ctaText == 'Shop Now') ? l10n.shopNow : d.ctaText;

    final borderRadius = BorderRadius.circular(22);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _onBannerTap(),
        behavior: HitTestBehavior.opaque,
        child: Material(
        type: MaterialType.card,
        elevation: isDark ? 4 : 6,
        shadowColor: d.gradientColors.first.withValues(
          alpha: isDark ? 0.4 : 0.25,
        ),
        surfaceTintColor: d.gradientColors.first.withValues(alpha: 0.08),
        borderRadius: borderRadius,
        color: cs.surface,
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: d.gradientColors.first.withValues(
                alpha: isDark ? 0.12 : 0.06,
              ),
              width: 0.5,
            ),
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              // ═══ LEFT TEXT ═══
              Expanded(
                flex: 5,
                child: Container(
                  color: cs.surface,
                  padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title — slide from left
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              height: 1.1,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Subtitle — slide from left (delayed)
                      SlideTransition(
                        position: _subtitleSlide,
                        child: FadeTransition(
                          opacity: _subtitleFade,
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.75),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Accent — elastic scale pop
                      if (accentPre.isNotEmpty || accentValue.isNotEmpty)
                        FadeTransition(
                          opacity: _accentFade,
                          child: ScaleTransition(
                            scale: _accentScale,
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  if (accentPre.isNotEmpty)
                                    TextSpan(
                                      text: accentPre,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  TextSpan(
                                    text: accentValue,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDark
                                          ? cs.primary
                                          : d.accentColorParsed,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // CTA — slide up + continuous glow pulse
                      SlideTransition(
                        position: _ctaSlide,
                        child: FadeTransition(
                          opacity: _ctaFade,
                          child: Transform.scale(
                            scale: pulseScale,
                            child: Material(
                              elevation: 4 + (_pulse.value * 4),
                              shadowColor: cs.primary.withValues(
                                alpha: isDark ? 0.5 : 0.35,
                              ),
                              surfaceTintColor: cs.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              color: cs.primary,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cta,
                                      style: TextStyle(
                                        color: cs.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: cs.onPrimary,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ═══ RIGHT IMAGE ═══
              Expanded(
                flex: 5,
                child: FadeTransition(
                  opacity: _bgFade,
                  child: Stack(
                    children: [
                      // Gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: d.gradientColors,
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(22),
                            bottomRight: Radius.circular(22),
                          ),
                        ),
                      ),
                      // Overlay sombre en dark mode pour harmoniser les couleurs vives
                      if (isDark)
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.45),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                          ),
                        ),

                      // Shimmer sweep (diagonal light)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(22),
                            bottomRight: Radius.circular(22),
                          ),
                          child: Transform.translate(
                            offset: Offset(
                              -200 + (shimmerT * 400),
                              -100 + (shimmerT * 200),
                            ),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Container(
                                width: 60,
                                height: 300,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.06),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Decorative ring
                      Positioned(
                        top: -25,
                        right: -25,
                        child: FadeTransition(
                          opacity: _decoFade,
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.07),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Decorative filled circle
                      Positioned(
                        bottom: -35,
                        left: -20,
                        child: FadeTransition(
                          opacity: _decoFade,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                      ),

                      // Watermark
                      Positioned(
                        right: -6,
                        top: 6,
                        child: FadeTransition(
                          opacity: _decoFade,
                          child: Text(
                            d.watermark ?? '',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.06),
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),

                      // ── SHOE — float + parallax + entrance ──
                      Positioned(
                        top: -8,
                        left: -25,
                        right: -8,
                        bottom: 16,
                        child: FadeTransition(
                          opacity: _shoeFade,
                          child: SlideTransition(
                            position: _shoeSlide,
                            child: ScaleTransition(
                              scale: _shoeScale,
                              child: Transform.translate(
                                offset: Offset(_shoeParallax, floatY),
                                child: Transform.rotate(
                                  angle: d.shoeAngle,
                                  child: _ShoeImage(url: d.imageUrl),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom quality labels
                      Positioned(
                        bottom: 10,
                        right: 8,
                        child: FadeTransition(
                          opacity: _decoFade,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _QualityLabel('HIGH'),
                              _QualityLabel('QUALITY'),
                              _QualityLabel('MATERIALS'),
                            ],
                          ),
                        ),
                      ),

                      // Vertical tagline
                      Positioned(
                        right: 3,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: FadeTransition(
                            opacity: _decoFade,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                d.tagline ?? '',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHOE IMAGE with drop shadow
// ═════════════════════════════════════════════════════════════════════════════

class _ShoeImage extends StatelessWidget {
  const _ShoeImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ImageOptimizer.optimizedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) => Icon(
        Icons.shopping_bag_outlined,
        size: 60,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  QUALITY LABEL
// ═════════════════════════════════════════════════════════════════════════════

class _QualityLabel extends StatelessWidget {
  const _QualityLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 7,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}
