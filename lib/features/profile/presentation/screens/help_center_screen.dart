import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/support_config.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/router/app_router.dart';
import '../../../../gen_l10n/app_localizations.dart';

/// Page Centre d'aide — style Apple professionnel : appel, WhatsApp, chat assistant.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.helpCenter,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpCenterSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Barre de recherche
                  _SearchBar(theme: theme, l10n: l10n),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _GroupedSection(
                theme: theme,
                isDark: isDark,
                children: [
                  _GroupedRow(
                    theme: theme,
                    icon: LucideIcons.phone,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.helpCenterCallTitle,
                    subtitle: l10n.helpCenterCallDesc,
                    onTap: () => _launchPhone(context, l10n),
                    isFirst: true,
                    isLast: false,
                  ),
                  _GroupedRow(
                    theme: theme,
                    icon: LucideIcons.messageCircle,
                    iconColor: const Color(0xFF25D366),
                    title: l10n.helpCenterWhatsAppTitle,
                    subtitle: l10n.helpCenterWhatsAppDesc,
                    onTap: () => _launchWhatsApp(context, l10n),
                    isFirst: false,
                    isLast: false,
                  ),
                  _GroupedRow(
                    theme: theme,
                    icon: LucideIcons.bot,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.helpCenterChatTitle,
                    subtitle: l10n.helpCenterChatDesc,
                    onTap: () => context.push(AppRoutes.chatAssistant),
                    isFirst: false,
                    isLast: false,
                  ),
                  _GroupedRow(
                    theme: theme,
                    icon: LucideIcons.helpCircle,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.faq,
                    subtitle: l10n.helpCenterFaqDesc,
                    onTap: () => context.push(AppRoutes.faq),
                    isFirst: false,
                    isLast: false,
                  ),
                  _GroupedRow(
                    theme: theme,
                    icon: LucideIcons.mail,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.helpCenterContactTitle,
                    subtitle: SupportConfig.email,
                    subtitleStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () => _launchEmail(context, l10n),
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Text(
                l10n.helpCenterHoursTitle.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: _GroupedSection(
                theme: theme,
                isDark: isDark,
                children: [
                  _GroupedRow(
                    theme: theme,
                    title: l10n.helpCenterHours,
                    titleStyle: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurface,
                    ),
                    isFirst: true,
                    isLast: true,
                    showChevron: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, AppLocalizations l10n) async {
    final uri = Uri(
      scheme: 'mailto',
      path: SupportConfig.email,
      queryParameters: {'subject': 'SOLMA - ${l10n.helpCenter}'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppToast.show(context, message: l10n.errorGeneric, isError: true);
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, AppLocalizations l10n) async {
    final uri = Uri(scheme: 'tel', path: SupportConfig.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppToast.show(context, message: l10n.errorGeneric, isError: true);
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, AppLocalizations l10n) async {
    final msg = l10n.localeName.startsWith('fr')
        ? 'Bonjour, j\'ai une question concernant SOLMA.'
        : 'Hi, I have a question about SOLMA.';
    final encoded = Uri.encodeComponent(msg);
    final uri = Uri.parse(
      'https://wa.me/${SupportConfig.whatsAppNumber}?text=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppToast.show(context, message: l10n.errorGeneric, isError: true);
      }
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.theme,
    required this.l10n,
  });

  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.faq),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.helpCenterSearchHint,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  const _GroupedSection({
    required this.theme,
    required this.isDark,
    required this.children,
  });

  final ThemeData theme;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: AppShadows.card(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _GroupedRow extends StatelessWidget {
  const _GroupedRow({
    required this.theme,
    required this.title,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.subtitleStyle,
    this.titleStyle,
    this.onTap,
    required this.isFirst,
    required this.isLast,
    this.showChevron = true,
  });

  final ThemeData theme;
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.08),
                    ),
                  ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: titleStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: subtitleStyle ??
                            theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron && onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
