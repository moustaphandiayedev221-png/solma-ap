import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/address_model.dart';
import '../providers/address_provider.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.addressId});

  final String? addressId;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  bool _isDefault = false;
  bool _isLoading = false;
  CountryCode? _selectedCountryForAddress;
  CountryCode? _selectedPhoneCode;
  String _initialCountrySelection = 'SN';
  String _initialPhoneSelection = '+221';
  List<csc.State> _regions = [];
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _fullNameController = TextEditingController();
    _line1Controller = TextEditingController();
    _line2Controller = TextEditingController();
    final defaultCountryName =
        CountryCode.tryFromCountryCode(_initialCountrySelection)?.name ?? 'Senegal';
    _countryController = TextEditingController(text: defaultCountryName);
    _phoneController = TextEditingController();
  }

  bool _initialized = false;

  void _fillFromAddress(AddressModel addr) {
    if (_initialized) return;
    _initialized = true;
    _labelController.text = addr.label ?? '';
    _fullNameController.text = addr.fullName;
    _line1Controller.text = addr.line1;
    _line2Controller.text = addr.line2 ?? '';
    _countryController.text = addr.country;
    final code = addr.countryCode ?? _countryNameToCode(addr.country);
    _initialCountrySelection = code ?? 'SN';
    _selectedRegion = addr.region ?? (addr.city.isNotEmpty ? addr.city : null);
    _selectedCountryForAddress = code != null ? CountryCode.tryFromCountryCode(code) : null;
    if (code != null) _loadRegions(code);
    _parseInitialPhone(addr.phone);
    setState(() => _isDefault = addr.isDefault);
  }

  Future<void> _loadRegions(String countryCode) async {
    try {
      final states = await csc.getStatesOfCountry(countryCode);
      if (mounted) {
        setState(() {
          _regions = states;
          if (!_regions.any((s) => s.name == _selectedRegion)) {
            _selectedRegion = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _regions = []);
    }
  }

  static String? _countryNameToCode(String name) {
    if (name.isEmpty) return null;
    final lower = name.toLowerCase().trim();
    const map = {
      'senegal': 'SN', 'sénégal': 'SN', 'guinée': 'GN', 'guinee': 'GN', 'guinea': 'GN',
      'france': 'FR', 'mali': 'ML', 'mauritanie': 'MR', 'côte d\'ivoire': 'CI',
      'cote d\'ivoire': 'CI', 'burkina faso': 'BF', 'togo': 'TG', 'bénin': 'BJ',
      'benin': 'BJ', 'niger': 'NE', 'gambie': 'GM',
    };
    return map[lower] ?? map[lower.replaceAll(RegExp(r'[éèêë]'), 'e')];
  }

  void _parseInitialPhone(String? phone) {
    if (phone == null || phone.isEmpty) return;
    final trimmed = phone.trim().replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (trimmed.startsWith('+')) {
      for (int len = 4; len >= 1; len--) {
        if (trimmed.length <= 1 + len) continue;
        final candidate = trimmed.substring(0, 1 + len);
        if (CountryCode.tryFromDialCode(candidate) != null) {
          _initialPhoneSelection = candidate;
          _phoneController.text = trimmed.substring(1 + len);
          return;
        }
      }
    }
    _phoneController.text = trimmed;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final repo = ref.read(addressRepositoryProvider);
    final country = _selectedCountryForAddress?.name ?? _countryController.text.trim();
    final countryCode = _selectedCountryForAddress?.code ?? CountryCode.tryFromCountryCode(_initialCountrySelection)?.code;
    final dialCode = _selectedPhoneCode?.dialCode ?? _initialPhoneSelection;
    final phoneOnly = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final fullPhone = phoneOnly.isEmpty ? null : '$dialCode$phoneOnly';

    setState(() => _isLoading = true);
    try {
      final address = AddressModel(
        id: widget.addressId ?? '',
        userId: user.id,
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        fullName: _fullNameController.text.trim(),
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim().isEmpty ? null : _line2Controller.text.trim(),
        city: _selectedRegion ?? '',
        postalCode: null,
        country: country,
        region: _selectedRegion,
        countryCode: countryCode,
        phone: fullPhone,
        isDefault: _isDefault,
      );
      if (widget.addressId != null) {
        await repo.update(address);
      } else {
        await repo.insert(user.id, address);
      }
      ref.invalidate(userAddressesProvider);
      ref.invalidate(defaultAddressProvider);
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.addressSaved);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: AppLocalizations.of(context)!.errorGeneric, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final addressAsync = widget.addressId != null
        ? ref.watch(addressByIdProvider(widget.addressId!))
        : null;

    if (widget.addressId != null) {
      ref.listen(addressByIdProvider(widget.addressId!), (prev, next) {
        if (next.hasValue && next.value != null && !_initialized) {
          final addr = next.value!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_initialized) _fillFromAddress(addr);
          });
        }
      });
      // Remplir immédiatement si les données sont déjà disponibles (cache)
      final addr = addressAsync?.valueOrNull;
      if (addr != null && !_initialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_initialized) _fillFromAddress(addr);
        });
      }
    }

    if (widget.addressId != null && addressAsync != null && addressAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => context.pop(),
          ),
          title: Text(l10n.editAddress),
        ),
        body: const AppPageLoader(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.addressId != null ? l10n.editAddress : l10n.addAddress),
        actions: widget.addressId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.deleteAddress),
                        content: Text(l10n.deleteAddressConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            child: Text(l10n.deleteAddress),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && widget.addressId != null) {
                      await ref.read(addressRepositoryProvider).delete(widget.addressId!);
                      ref.invalidate(userAddressesProvider);
                      ref.invalidate(defaultAddressProvider);
                      if (!context.mounted) return;
                      AppToast.show(context, message: l10n.addressDeleted);
                      context.pop();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l10n.addressLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                border: const OutlineInputBorder(),
                hintText: l10n.fullNameHint,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fullNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _line1Controller,
              decoration: InputDecoration(
                labelText: l10n.addressLine1,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.addressLine1Required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _line2Controller,
              decoration: InputDecoration(
                labelText: l10n.addressLine2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormField<String>(
              initialValue: _countryController.text,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.countryRequired : null,
              builder: (field) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.country,
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: CountryCodePicker(
                    onChanged: (c) {
                      _selectedCountryForAddress = c;
                      _countryController.text = c.name ?? '';
                      field.didChange(c.name ?? '');
                      _selectedRegion = null;
                      if (c.code != null) _loadRegions(c.code!);
                    },
                    onInit: (c) {
                      _selectedCountryForAddress ??= c;
                      _countryController.text = c?.name ?? '';
                      if (c?.code != null) _loadRegions(c!.code!);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        field.didChange(c?.name ?? '');
                      });
                    },
                    initialSelection: _initialCountrySelection,
                    showCountryOnly: true,
                    showOnlyCountryWhenClosed: true,
                    favorite: const ['SN', 'FR', 'BF', 'CI', 'US', 'GB', 'DE'],
                    padding: EdgeInsets.zero,
                    hideMainText: false,
                    showFlagMain: true,
                    showFlagDialog: true,
                    hideSearch: false,
                    flagWidth: 28,
                  ),
                );
              },
            ),
            if (_regions.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: l10n.regionOptional,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('— ${l10n.region}'),
                  ),
                  ..._regions.map((s) => DropdownMenuItem<String>(
                    value: s.name,
                    child: Text(s.name),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedRegion = v),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  CountryCodePicker(
                    onChanged: (c) => setState(() => _selectedPhoneCode = c),
                    onInit: (c) => _selectedPhoneCode ??= c,
                    initialSelection: _initialPhoneSelection,
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
                        labelText: l10n.phone,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(l10n.setAsDefault),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.saveAddress,
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
