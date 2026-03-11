import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_shadows.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/responsive/responsive_module.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/router/app_router.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/address_model.dart';
import '../providers/address_provider.dart';
import '../providers/profile_provider.dart';

const double _kFieldRadius = 12;

/// Page d'édition du profil — exactement comme la maquette :
/// carte blanche infos (Fullname, Téléphone avec indicatif pays, Email, Date de naissance),
/// carte Adresse & Emplacement avec lignes d'adresses et bouton + Add Location.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  bool _hasInitialized = false;
  CountryCode? _selectedCountryCode;
  String _initialCountrySelection = '+221';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _parseInitialPhone(String? phone) {
    if (phone == null || phone.isEmpty) return;
    final trimmed = phone.trim().replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (trimmed.startsWith('+')) {
      for (int len = 4; len >= 1; len--) {
        if (trimmed.length <= 1 + len) continue;
        final candidate = trimmed.substring(0, 1 + len);
        if (CountryCode.tryFromDialCode(candidate) != null) {
          _initialCountrySelection = candidate;
          _phoneController.text = trimmed.substring(1 + len);
          return;
        }
      }
    }
    _phoneController.text = trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final dialCode = _selectedCountryCode?.dialCode ?? _initialCountrySelection;
    final fullPhone = _phoneController.text.trim().isEmpty
        ? ''
        : '$dialCode${_phoneController.text.trim().replaceAll(RegExp(r'\s+'), '')}';

    setState(() => _isLoading = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            user.id,
            fullName: _fullNameController.text.trim(),
            phone: fullPhone,
          );
      ref.invalidate(profileProvider);
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.profileUpdated);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.errorGeneric, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static const double _cardRadius = 16;
  static const double _fieldRadius = _kFieldRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = context.responsive;
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);
    final addressesAsync = ref.watch(userAddressesProvider);

    final isDark = theme.brightness == Brightness.dark;
    final screenBg = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;

    if (user == null) {
      return Scaffold(
        backgroundColor: screenBg,
        appBar: AppBar(
          backgroundColor: screenBg,
          title: Text(l10n.editProfileTitle),
        ),
        body: Center(child: Text(l10n.notSignedIn)),
      );
    }

    final profile = profileAsync.valueOrNull;
    final addresses = addressesAsync.valueOrNull ?? [];

    if (profile != null && !_hasInitialized) {
      _hasInitialized = true;
      _fullNameController.text = profile.fullName ?? user.userMetadata?['full_name'] as String? ?? user.email?.split('@').first ?? '';
      _parseInitialPhone(profile.phone);
    }

    final email = user.email ?? '';

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.editProfileTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            r.horizontalPadding,
            16,
            r.horizontalPadding,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Carte Informations personnelles ───
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(_cardRadius),
                  boxShadow: AppShadows.card(context),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(l10n.fullName),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration(hint: l10n.fullNameHint),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(l10n.phoneNumber),
                    const SizedBox(height: 8),
                    _buildPhoneField(theme, l10n),
                    const SizedBox(height: 20),
                    _buildLabel(l10n.emailAddress),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: email,
                      enabled: false,
                      decoration: _inputDecoration().copyWith(
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_fieldRadius),
                          ),
                        ),
                        child: Text(_isLoading ? l10n.loading : l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Carte Adresse & Emplacement ───
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(_cardRadius),
                  boxShadow: AppShadows.card(context),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 22,
                          color: const Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.addressAndLocation,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (addresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          l10n.noAddresses,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...addresses.map((addr) => _AddressRow(
                            address: addr,
                            onTap: () => context.push('${AppRoutes.addressEdit}/${addr.id}'),
                            theme: theme,
                          )),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(_fieldRadius),
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.addressNew),
                          borderRadius: BorderRadius.circular(_fieldRadius),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(_fieldRadius),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 22, color: theme.colorScheme.onSurface),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.addLocation,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildPhoneField(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: (c) => setState(() => _selectedCountryCode = c),
            onInit: (c) => _selectedCountryCode ??= c,
            initialSelection: _initialCountrySelection,
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            favorite: const ['+221', '+33', '+226', '+225', '+1', '+44', '+49'],
            padding: EdgeInsets.zero,
            textStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            flagWidth: 28,
            hideSearch: false,
            showFlagMain: true,
            showFlagDialog: true,
            alignLeft: false,
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: l10n.phoneNumberHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuile d'adresse : carte blanche arrondie, bordure grise légère, 2 lignes + chevron (style maquette).
class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.address,
    required this.onTap,
    required this.theme,
  });

  final AddressModel address;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = address.label ?? address.fullName;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(_kFieldRadius),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_kFieldRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.singleLine,
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
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

