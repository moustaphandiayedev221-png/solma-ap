import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

/// Splash ultra-moderne — Connecté → Main ; Onboarding vu → Main ; sinon → Onboarding
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      context.go(AppRoutes.main);
      return;
    }
    final onboardingDone = await ref.read(isOnboardingDoneProvider.future);
    if (!mounted) return;
    if (onboardingDone) {
      context.go(AppRoutes.main);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arrière-plan gradient animé
          _AnimatedGradientBackground(isDark: isDark),

          // Orbes flottants décoratifs
          ..._buildFloatingOrbs(isDark),

          // Contenu principal
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo avec effet de révélation
                  _LogoWithGlow(
                    glowAnimation: _glowAnimation,
                    shimmerController: _shimmerController,
                    isDark: isDark,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 20),
                  // Tagline
                  Text(
                    AppConstants.appTagline,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: isDark ? 0.85 : 0.75,
                      ),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                  const Spacer(flex: 2),
                  // Loader moderne
                  _SplashLoader(isDark: isDark)
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms)
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(bool isDark) {
    final colors = isDark
        ? [
            const Color(0xFF2E7D32).withValues(alpha: 0.08),
            const Color(0xFF1565C0).withValues(alpha: 0.06),
            const Color(0xFF6A1B9A).withValues(alpha: 0.05),
          ]
        : [
            const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            const Color(0xFF1565C0).withValues(alpha: 0.03),
            const Color(0xFF2E7D32).withValues(alpha: 0.025),
          ];
    return [
      Positioned(
        top: MediaQuery.of(context).size.height * 0.12,
        left: -60,
        child: _FloatingOrb(
          size: 200,
          color: colors[0],
          duration: 4000,
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        right: -80,
        child: _FloatingOrb(
          size: 240,
          color: colors[1],
          duration: 5000,
        ),
      ),
      Positioned(
        bottom: MediaQuery.of(context).size.height * 0.2,
        left: MediaQuery.of(context).size.width * 0.2,
        child: _FloatingOrb(
          size: 140,
          color: colors[2],
          duration: 4500,
        ),
      ),
    ];
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({required this.isDark});

  final bool isDark;

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + _animation.value * 0.4,
                -0.8 + _animation.value * 0.2,
              ),
              end: Alignment(
                1 - _animation.value * 0.3,
                0.9 - _animation.value * 0.2,
              ),
              colors: widget.isDark
                  ? [
                      const Color(0xFF0D0D0D),
                      const Color(0xFF1A1A1A),
                      const Color(0xFF0D1117),
                    ]
                  : [
                      const Color(0xFFFAFBFC),
                      Color.lerp(
                        const Color(0xFFF5F5F0),
                        const Color(0xFFE8EEF2),
                        _animation.value,
                      )!,
                      const Color(0xFFF0F4F8),
                    ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingOrb extends StatefulWidget {
  const _FloatingOrb({
    required this.size,
    required this.color,
    required this.duration,
  });

  final double size;
  final Color color;
  final int duration;

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * _animation.value,
          height: widget.size * _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color,
                widget.color.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow({
    required this.glowAnimation,
    required this.shimmerController,
    required this.isDark,
  });

  final Animation<double> glowAnimation;
  final AnimationController shimmerController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([glowAnimation, shimmerController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow derrière le texte
            Text(
              AppConstants.appName.toUpperCase(),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: theme.colorScheme.primary.withValues(
                  alpha: glowAnimation.value * 0.15,
                ),
                shadows: [
                  Shadow(
                    color: theme.colorScheme.primary.withValues(
                      alpha: glowAnimation.value * 0.2,
                    ),
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            // Texte principal avec dégradé
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(
                  -1 + (shimmerController.value * 2),
                  0,
                ),
                end: Alignment(
                  1 + (shimmerController.value * 2),
                  0,
                ),
                colors: isDark
                    ? [
                        const Color(0xFFFFFFFF),
                        const Color(0xFFE0E0E0),
                        const Color(0xFFFFFFFF),
                      ]
                    : [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF424242),
                        const Color(0xFF1A1A1A),
                      ],
              ).createShader(bounds),
              child: Text(
                AppConstants.appName.toUpperCase(),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SplashLoader extends StatefulWidget {
  const _SplashLoader({required this.isDark});

  final bool isDark;

  @override
  State<_SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<_SplashLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return SizedBox(
      width: 48,
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final progress = _controller.value;
          final dot1 = (progress * 3).clamp(0.0, 1.0);
          final dot2 = ((progress * 3) - 1).clamp(0.0, 1.0);
          final dot3 = ((progress * 3) - 2).clamp(0.0, 1.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LoaderDot(
                size: 8,
                color: color,
                opacity: 0.3 + 0.7 * dot1,
              ),
              _LoaderDot(
                size: 8,
                color: color,
                opacity: 0.3 + 0.7 * dot2,
              ),
              _LoaderDot(
                size: 8,
                color: color,
                opacity: 0.3 + 0.7 * dot3,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoaderDot extends StatelessWidget {
  const _LoaderDot({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.5),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
