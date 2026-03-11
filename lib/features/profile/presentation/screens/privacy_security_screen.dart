import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Page Confidentialité et sécurité — mot de passe, données, politique.
class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.privacySecurity),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacySecuritySubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.privacySecuritySectionAccount,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.key,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.privacySecurityChangePassword),
                    subtitle: Text(
                      l10n.privacySecurityChangePasswordDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => _showChangePasswordSheet(context, ref, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.privacySecuritySectionData,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      LucideIcons.fileText,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.privacyPolicy),
                    subtitle: Text(
                      l10n.privacySecurityPolicyDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => context.push(AppRoutes.privacyPolicy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.privacySecuritySectionDanger,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SoftCard(
              onTap: () => _showDeleteAccountDialog(context, ref, l10n),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.trash2,
                    size: 22,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.privacySecurityDeleteAccount,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.privacySecurityDeleteAccountDesc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.privacySecurityChangePassword,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.privacySecurityNewPassword,
                  hintText: l10n.passwordMinLength,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (v.length < 6) return l10n.passwordMinLength;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newPassword = controller.text.trim();
                    try {
                      await ref
                          .read(authRepositoryProvider)
                          .updatePassword(newPassword);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        AppToast.show(ctx, message: l10n.privacySecurityPasswordUpdated);
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        AppToast.show(ctx, message: l10n.errorGeneric, isError: true);
                      }
                    }
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.privacySecurityDeleteAccount),
        content: Text(l10n.privacySecurityDeleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppToast.show(context, message: l10n.privacySecurityDeleteAccountContact);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.privacySecurityDeleteAccount),
          ),
        ],
      ),
    );
  }
}
