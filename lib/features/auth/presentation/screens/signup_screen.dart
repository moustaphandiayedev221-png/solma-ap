import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_shadows.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/native_auth_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_button.dart';

/// Écran d'inscription — design moderne premium avec OAuth
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.errorPrefix(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      if (e is UserCanceledAuthException) {
        AppToast.show(context, message: AppLocalizations.of(context)!.connectionCancelled);
      } else {
        AppToast.show(context, message: AppLocalizations.of(context)!.errorPrefix(e.toString()), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _signUpWithApple() async {
    setState(() => _isAppleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
      if (!mounted) return;
      context.go(AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      if (e is UserCanceledAuthException) {
        AppToast.show(context, message: AppLocalizations.of(context)!.connectionCancelled);
      } else {
        AppToast.show(context, message: AppLocalizations.of(context)!.errorPrefix(e.toString()), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo / Brand
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.logo(context),
                        ),
                        child: Material(
                          color: theme.colorScheme.primary,
                          elevation: 0,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Center(
                            child: Text(
                              'C',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.createAccount,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.joinSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Full name
                    AuthTextField(
                      controller: _nameController,
                      label: l10n.fullName,
                      hint: l10n.fullNameHint,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.nameRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Email
                    AuthTextField(
                      controller: _emailController,
                      label: l10n.email,
                      hint: l10n.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.emailRequired;
                        if (!v.contains('@')) return l10n.emailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password
                    AuthTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.passwordRequired;
                        if (v.length < 6) return l10n.passwordMinLength;
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Sign up button
                    PrimaryButton(
                      label: l10n.signUp,
                      onPressed: _signUp,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    OrDivider(text: l10n.orContinueWith),
                    const SizedBox(height: 20),

                    // Social buttons — horizontal row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialIconButton(
                          icon: const GoogleIcon(size: 24),
                          onPressed: _signUpWithGoogle,
                          isLoading: _isGoogleLoading,
                        ),
                        const SizedBox(width: 16),
                        SocialIconButton(
                          icon: Icon(
                            Icons.apple,
                            size: 28,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: _signUpWithApple,
                          isLoading: _isAppleLoading,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Terms text — liens cliquables
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(text: l10n.termsPrefix),
                            TextSpan(
                              text: l10n.termsOfService,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.push(AppRoutes.privacyPolicy),
                            ),
                            TextSpan(text: l10n.andText),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.push(AppRoutes.privacyPolicy),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            l10n.signIn,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
