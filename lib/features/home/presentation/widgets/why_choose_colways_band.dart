import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../gen_l10n/app_localizations.dart';

/// Bande noire divisée en deux : gauche "Pourquoi choisir SOLMA?" avec icône,
/// droite texte défilant verticalement (Protection des données, Paiement sécurisé, ...).
class WhyChooseColwaysBand extends StatefulWidget {
  const WhyChooseColwaysBand({super.key});

  @override
  State<WhyChooseColwaysBand> createState() => _WhyChooseColwaysBandState();
}

class _WhyChooseColwaysBandState extends State<WhyChooseColwaysBand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.forward(from: 0);
            }
          });
    _controller.addListener(_onAnimationTick);
    _controller.forward();
  }

  void _onAnimationTick() {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      final pos = _scrollController.position;
      if (!pos.hasContentDimensions) return;
      final maxScroll = pos.maxScrollExtent;
      if (maxScroll <= 0) return;
      final offset = _controller.value * maxScroll;
      _scrollController.jumpTo(offset);
    } catch (_) {
      // Évite un crash si le scroll est dans un état invalide (ex. changement d'onglet).
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationTick);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.shield_outlined, l10n.dataProtection, const Color(0xFF42A5F5)),
      (Icons.credit_card_outlined, l10n.securePayment, const Color(0xFF66BB6A)),
      (Icons.local_shipping_outlined, l10n.deliveryWorldwide, const Color(0xFFFFB74D)),
    ];
    final r = context.responsive;
    final bandHeight = r.isCompactSmall ? 24.0 : 28.0;
    final leftFontSize = r.isCompactSmall ? 9.0 : 10.0;
    final rightFontSize = r.isCompactSmall ? 10.0 : 11.0;
    final itemHeight = bandHeight;

    const radius = 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.privacyPolicy),
        behavior: HitTestBehavior.opaque,
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final colors = isDark
                ? [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFFFFFFF),
                  ]
                : [
                    const Color(0xFF000000),
                    const Color(0xFF0A0A0A),
                    const Color(0xFF000000),
                  ];
            return Container(
              height: bandHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: _BandContent(
                  bandHeight: bandHeight,
                  items: items,
                  r: r,
                  l10n: l10n,
                  leftFontSize: leftFontSize,
                  rightFontSize: rightFontSize,
                  itemHeight: itemHeight,
                  scrollController: _scrollController,
                  isDark: isDark,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BandContent extends StatelessWidget {
  const _BandContent({
    required this.bandHeight,
    required this.items,
    required this.r,
    required this.l10n,
    required this.leftFontSize,
    required this.rightFontSize,
    required this.itemHeight,
    required this.scrollController,
    required this.isDark,
  });

  final double bandHeight;
  final List<(IconData, String, Color)> items;
  final ResponsiveValues r;
  final AppLocalizations l10n;
  final double leftFontSize;
  final double rightFontSize;
  final double itemHeight;
  final ScrollController scrollController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
          ),
          Row(
            children: [
                      // Partie 1 : Pourquoi choisir SOLMA?
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.98),
                                      size: r.isCompactSmall ? 12 : 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          l10n.whyChooseSOLMA,
                                          style: TextStyle(
                                            color: isDark ? Colors.black : Colors.white.withValues(alpha: 0.98),
                                            fontSize: leftFontSize,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                            height: 1.15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ),
                              // Séparateur élégant
                              Container(
                                width: 1,
                                height: bandHeight * 0.45,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                                      (isDark ? Colors.black : Colors.white).withValues(alpha: 0.35),
                                      (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Partie 2 : défilement vertical
                              Expanded(
                                flex: 6,
                                child: ClipRect(
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                        SingleChildScrollView(
                                        controller: scrollController,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(right: 28),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          ...items.map(
                                            (item) => _ScrollingItem(
                                                icon: item.$1,
                                                text: item.$2,
                                                iconColor: item.$3,
                                                fontSize: rightFontSize,
                                                height: itemHeight,
                                                iconSize: r.isCompactSmall ? 14 : 16,
                                                isDark: isDark,
                                              ),
                                            ),
                                            ...items.map(
                                              (item) => _ScrollingItem(
                                                icon: item.$1,
                                                text: item.$2,
                                                iconColor: item.$3,
                                                fontSize: rightFontSize,
                                                height: itemHeight,
                                                iconSize: r.isCompactSmall ? 14 : 16,
                                                isDark: isDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          color: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.5),
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScrollingItem extends StatelessWidget {
  const _ScrollingItem({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.fontSize,
    required this.height,
    required this.iconSize,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final double fontSize;
  final double height;
  final double iconSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.95),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
