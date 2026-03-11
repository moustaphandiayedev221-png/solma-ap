import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding professionnel — 3 slides avec illustrations Lucide, bouton Passer, CTA premium.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<({IconData icon, Color accent})> _slides = [
    (icon: LucideIcons.shoppingBag, accent: Color(0xFF1A1A1A)),
    (icon: LucideIcons.footprints, accent: Color(0xFF2E7D32)),
    (icon: LucideIcons.truck, accent: Color(0xFF1565C0)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingRepositoryProvider).setOnboardingDone();
    if (!mounted) return;
    context.go(AppRoutes.main);
  }

  void _onSkip() => _completeOnboarding();

  void _onGetStarted() => _completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.scaffoldBackgroundColor,
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Passer (Skip)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      l10n.onboardingSkip,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final titles = [
                      l10n.onboardingTitle1,
                      l10n.onboardingTitle2,
                      l10n.onboardingTitle3,
                    ];
                    final subtitles = [
                      l10n.onboardingSubtitle1,
                      l10n.onboardingSubtitle2,
                      l10n.onboardingSubtitle3,
                    ];
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          _SlideIllustration(
                            icon: slide.icon,
                            accent: slide.accent,
                            isDark: isDark,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(
                                begin: const Offset(0.92, 0.92),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 48),
                          Text(
                            titles[index],
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 400.ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 16),
                          Text(
                            subtitles[index],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 250.ms, duration: 400.ms)
                              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Indicateur + Bouton
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _slides.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3.2,
                    spacing: 8,
                    dotColor: theme.colorScheme.outline.withValues(alpha: 0.4),
                    activeDotColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: _currentPage == _slides.length - 1
                          ? l10n.getStarted
                          : l10n.next,
                      onPressed: () {
                        if (_currentPage == _slides.length - 1) {
                          _onGetStarted();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                    if (_currentPage == _slides.length - 1) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(onboardingRepositoryProvider)
                                  .setOnboardingDone();
                              if (!context.mounted) return;
                              context.go(AppRoutes.login);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.signIn,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideIllustration extends StatelessWidget {
  const _SlideIllustration({
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  final IconData icon;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card(context),
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 88,
            color: accent,
          ),
        ),
      ),
    );
  }
}
