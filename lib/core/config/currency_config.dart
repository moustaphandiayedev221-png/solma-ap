import 'package:flutter/foundation.dart';
import '../../gen_l10n/app_localizations.dart';

/// Configuration des devises pour l'application.
/// Supporte 150+ devises dont XOF, USD, EUR, GNF (franc guinéen).
class CurrencyConfig {
  CurrencyConfig._();

  /// Devise de base des prix (XOF)
  static const String baseCurrencyCode = 'XOF';

  /// Liste des devises principales affichées (ordre de priorité)
  static const List<CurrencyInfo> popularCurrencies = [
    CurrencyInfo(
      code: 'XOF',
      symbol: 'CFA',
      name: 'Franc CFA BCEAO',
      decimalPlaces: 0,
      flag: '🇧🇫',
      nameFr: 'Franc CFA BCEAO',
      nameEn: 'West African CFA franc',
    ),
    CurrencyInfo(
      code: 'GNF',
      symbol: 'FG',
      name: 'Franc guinéen',
      decimalPlaces: 0,
      flag: '🇬🇳',
      nameFr: 'Franc guinéen',
      nameEn: 'Guinean Franc',
    ),
    CurrencyInfo(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      decimalPlaces: 2,
      flag: '🇺🇸',
      nameFr: 'Dollar américain',
      nameEn: 'US Dollar',
    ),
    CurrencyInfo(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      decimalPlaces: 2,
      flag: '🇪🇺',
      nameFr: 'Euro',
      nameEn: 'Euro',
    ),
    CurrencyInfo(
      code: 'XAF',
      symbol: 'FCFA',
      name: 'Franc CFA BEAC',
      decimalPlaces: 0,
      flag: '🇨🇲',
      nameFr: 'Franc CFA BEAC',
      nameEn: 'Central African CFA franc',
    ),
    CurrencyInfo(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      decimalPlaces: 2,
      flag: '🇬🇧',
      nameFr: 'Livre sterling',
      nameEn: 'British Pound',
    ),
    CurrencyInfo(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      decimalPlaces: 2,
      flag: '🇨🇭',
      nameFr: 'Franc suisse',
      nameEn: 'Swiss Franc',
    ),
    CurrencyInfo(
      code: 'CAD',
      symbol: '\$',
      name: 'Canadian Dollar',
      decimalPlaces: 2,
      flag: '🇨🇦',
      nameFr: 'Dollar canadien',
      nameEn: 'Canadian Dollar',
    ),
    CurrencyInfo(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      decimalPlaces: 0,
      flag: '🇯🇵',
      nameFr: 'Yen japonais',
      nameEn: 'Japanese Yen',
    ),
    CurrencyInfo(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      decimalPlaces: 2,
      flag: '🇨🇳',
      nameFr: 'Yuan chinois',
      nameEn: 'Chinese Yuan',
    ),
    CurrencyInfo(
      code: 'NGN',
      symbol: '₦',
      name: 'Nigerian Naira',
      decimalPlaces: 2,
      flag: '🇳🇬',
      nameFr: 'Naira nigérian',
      nameEn: 'Nigerian Naira',
    ),
    CurrencyInfo(
      code: 'MAD',
      symbol: 'د.م.',
      name: 'Moroccan Dirham',
      decimalPlaces: 2,
      flag: '🇲🇦',
      nameFr: 'Dirham marocain',
      nameEn: 'Moroccan Dirham',
    ),
    CurrencyInfo(
      code: 'TND',
      symbol: 'د.ت',
      name: 'Tunisian Dinar',
      decimalPlaces: 2,
      flag: '🇹🇳',
      nameFr: 'Dinar tunisien',
      nameEn: 'Tunisian Dinar',
    ),
    CurrencyInfo(
      code: 'DZD',
      symbol: 'د.ج',
      name: 'Algerian Dinar',
      decimalPlaces: 2,
      flag: '🇩🇿',
      nameFr: 'Dinar algérien',
      nameEn: 'Algerian Dinar',
    ),
  ];

  /// Devise par défaut
  static CurrencyInfo get defaultCurrency =>
      popularCurrencies.firstWhere((c) => c.code == baseCurrencyCode);

  /// Obtient une devise par son code
  static CurrencyInfo? getCurrencyByCode(String code) {
    final upper = code.toUpperCase();
    try {
      return popularCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == upper,
      );
    } catch (_) {
      return null;
    }
  }

  /// Toutes les devises supportées (popularCurrencies pour l'instant)
  static List<CurrencyInfo> get supportedCurrencies => popularCurrencies;

  /// Formate un montant selon la devise
  static String formatAmount(double amount, CurrencyInfo currency) {
    final formatted = amount.toStringAsFixed(currency.decimalPlaces);
    if (currency.code == 'XOF' || currency.code == 'XAF' || currency.code == 'GNF') {
      return '$formatted ${currency.symbol}';
    }
    return '${currency.symbol}$formatted';
  }
}

/// Représentation d'une devise
@immutable
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.decimalPlaces,
    required this.flag,
    required this.nameFr,
    required this.nameEn,
  });

  final String code;
  final String symbol;
  final String name;
  final int decimalPlaces;
  final String flag;
  final String nameFr;
  final String nameEn;

  @override
  String toString() => '$flag $code';

  String get displayName => '$flag $name ($code)';

  String localizedName(AppLocalizations l10n) {
    final locale = l10n.localeName;
    if (locale.startsWith('fr')) return nameFr;
    return nameEn;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyInfo && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
