import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import 'package:colways/core/config/currency_config.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/data/fcm_token_repository.dart';
import '../providers/profile_provider.dart';
import '../providers/address_provider.dart';

/// Page profil — style image : carte header, statistiques 2x2, paramètres compte, support.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);
    final addressesAsync = ref.watch(userAddressesProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final selectedLocale = ref.watch(localeProvider);
    final locale = selectedLocale ?? Localizations.localeOf(context);
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.login);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final displayName =
        profileAsync.valueOrNull?.fullName ??
        user.userMetadata?['full_name'] as String? ??
        user.email?.split('@').first ??
        'User';
    final avatarUrl = profileAsync.valueOrNull?.avatarUrl;

    // Ville, Pays depuis la première adresse par défaut
    final addresses = addressesAsync.valueOrNull ?? [];
    final defaultAddr =
        addresses.where((a) => a.isDefault).firstOrNull ??
        addresses.firstOrNull;
    final locationText = defaultAddr != null
        ? '${defaultAddr.city}, ${defaultAddr.country}'
        : l10n.locationNotSet;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.horizontalPadding,
          r.verticalPadding,
          r.horizontalPadding,
          r.verticalPadding +
              MediaQuery.of(context).padding.bottom +
              15, // Espace sous Déconnexion pour le rendre visible au-dessus de la bottom nav
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Breakpoint.maxReadingWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carte header profil
              SoftCard(
                padding: EdgeInsets.all(r.isCompactSmall ? 16 : 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: r.isCompactSmall ? 32 : 40,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(
                              LucideIcons.user,
                              size: r.isCompactSmall ? 32 : 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              displayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => context.push(AppRoutes.addresses),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.mapPin,
                                    size: 16,
                                    color: const Color(0xFFEF6C00),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      locationText,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.editProfile),
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        l10n.edit,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Carte Statistiques
              SoftCard(
                padding: EdgeInsets.all(r.isCompactSmall ? 12 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.barChart2,
                              size: 18,
                              color: const Color(0xFFEF6C00),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.statistics,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.orderHistory),
                          child: Text(
                            '${l10n.moreDetails} >',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    statsAsync.when(
                      data: (stats) => _StatsGrid(
                        totalShipping: stats.totalOrders,
                        rating: stats.rating,
                        point: stats.points,
                        review: stats.reviewCount,
                        l10n: l10n,
                        theme: theme,
                      ),
                      loading: () => _StatsGrid(
                        totalShipping: 0,
                        rating: 0,
                        point: 0,
                        review: 0,
                        l10n: l10n,
                        theme: theme,
                      ),
                      error: (err, stackTrace) => _StatsGrid(
                        totalShipping: 0,
                        rating: 0,
                        point: 0,
                        review: 0,
                        l10n: l10n,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Carte Paramètres du compte
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileListTile(
                      icon: LucideIcons.shield,
                      title: l10n.privacySecurity,
                      onTap: () => context.push(AppRoutes.privacySecurity),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.bell,
                      title: l10n.notificationPreference,
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.creditCard,
                      title: l10n.paymentMethods,
                      onTap: () => context.push(AppRoutes.paymentMethods),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.languages,
                      title: l10n.language,
                      trailing: Text(
                        locale.languageCode == 'fr'
                            ? l10n.languageFrench
                            : l10n.languageEnglish,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _showLanguageSelector(context, ref),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.coins,
                      title: l10n.currency,
                      trailing: Builder(
                        builder: (context) {
                          final currentCurrency = ref.watch(currencyProvider);
                          return Text(
                            currentCurrency.code,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      onTap: () => _showCurrencyDialog(context, ref),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.moon,
                      title: l10n.darkMode,
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (v) {
                          ref.read(themeModeProvider.notifier).setMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                      showChevron: false,
                      onTap: () {
                        ref.read(themeModeProvider.notifier).setMode(
                          themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Carte Support & Information
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileListTile(
                      icon: LucideIcons.messageCircle,
                      title: l10n.faq,
                      onTap: () => context.push(AppRoutes.faq),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.helpCircle,
                      title: l10n.helpCenter,
                      onTap: () => context.push(AppRoutes.helpCenter),
                    ),
                    _divider(theme),
                    _ProfileListTile(
                      icon: LucideIcons.fileText,
                      title: l10n.privacyPolicy,
                      onTap: () => context.push(AppRoutes.privacyPolicy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Déconnexion
              SoftCard(
                onTap: () async {
                  final userId = ref.read(authRepositoryProvider).currentUser?.id;
                  if (userId != null) {
                    await FcmTokenRepository().removeToken(userId);
                  }
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.logOut,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.signOut,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: theme.colorScheme.outline.withValues(alpha: 0.3),
    );
  }

}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalShipping,
    required this.rating,
    required this.point,
    required this.review,
    required this.l10n,
    required this.theme,
  });

  final int totalShipping;
  final double rating;
  final int point;
  final int review;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l = l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatItem(label: l.totalShipping, value: '$totalShipping'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: l.rating,
                value: rating > 0 ? rating.toStringAsFixed(1) : '—',
                trailing: rating > 0 ? _StarRating(value: rating) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatItem(label: l.point, value: '$point'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(label: l.review, value: '$review'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 14, color: Colors.amber[700]),
        if (value < 4.5)
          Icon(Icons.star_half, size: 14, color: Colors.amber[700])
        else
          Icon(Icons.star, size: 14, color: Colors.amber[700]),
      ],
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            if (showChevron)
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => const _CurrencyDialogContent(),
  );
}

class _CurrencyDialogContent extends ConsumerStatefulWidget {
  const _CurrencyDialogContent();

  @override
  ConsumerState<_CurrencyDialogContent> createState() =>
      _CurrencyDialogContentState();
}

class _CurrencyDialogContentState extends ConsumerState<_CurrencyDialogContent> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentCurrency = ref.watch(currencyProvider);
    final filtered = CurrencyConfig.supportedCurrencies.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.code.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.nameFr.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q);
    }).toList();

    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        elevation: 0,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.dialog(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête avec gradient et bouton fermer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  theme.colorScheme.primary.withValues(alpha: 0.35),
                                  theme.colorScheme.primary.withValues(alpha: 0.15),
                                ]
                              : [
                                  theme.colorScheme.primary.withValues(alpha: 0.12),
                                  theme.colorScheme.primary.withValues(alpha: 0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.chip(context),
                            ),
                            child: Icon(
                              LucideIcons.circleDollarSign,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.currency,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.currencyInfoNote,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      LucideIcons.x,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'XOF, GNF, USD…',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    size: 22,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: isDark ? 0.5 : 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final currency = filtered[i];
                  final isSelected = currency == currentCurrency;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(currencyProvider.notifier).setCurrency(currency);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: isDark ? 0.6 : 0.8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                                  : theme.colorScheme.outline.withValues(alpha: 0.08),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  currency.flag,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.localizedName(l10n),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currency.code} · ${currency.symbol}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.check,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

void _showLanguageSelector(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final currentLocale = ref.read(localeProvider) ?? Localizations.localeOf(context);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                label: l10n.languageFrench,
                isSelected: currentLocale.languageCode == 'fr',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
                  Navigator.of(ctx).pop();
                },
                theme: theme,
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                label: l10n.languageEnglish,
                isSelected: currentLocale.languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.of(ctx).pop();
                },
                theme: theme,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
