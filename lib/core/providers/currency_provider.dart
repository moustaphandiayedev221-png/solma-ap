import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/currency_config.dart';
import '../services/exchange_rate_service.dart';

/// Provider des taux de change (cache 24h)
final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  return ExchangeRateService.instance.getRates(base: CurrencyConfig.baseCurrencyCode);
});

/// Provider pour la devise sélectionnée
final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyInfo>(
  (ref) => CurrencyNotifier(),
);

/// Provider pour le formatage des montants (avec conversion temps réel)
final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  final currency = ref.watch(currencyProvider);
  final ratesAsync = ref.watch(exchangeRatesProvider);
  final rates = ratesAsync.valueOrNull;
  return CurrencyFormatter(currency, rates);
});

/// Notifier pour gérer la sélection de la devise
class CurrencyNotifier extends StateNotifier<CurrencyInfo> {
  CurrencyNotifier() : super(CurrencyConfig.defaultCurrency) {
    _loadCurrency();
  }

  static const String _currencyKey = 'selected_currency';

  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString(_currencyKey);

      if (currencyCode != null) {
        final currency = CurrencyConfig.getCurrencyByCode(currencyCode);
        if (currency != null) {
          state = currency;
        }
      }
    } catch (e) {
      state = CurrencyConfig.defaultCurrency;
    }
  }

  Future<void> setCurrency(CurrencyInfo currency) async {
    state = currency;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);
    } catch (e) {
      // Erreur de sauvegarde
    }
  }

  Future<void> resetToDefault() async {
    await setCurrency(CurrencyConfig.defaultCurrency);
  }
}

/// Service pour formater les montants selon la devise actuelle (avec conversion)
class CurrencyFormatter {
  const CurrencyFormatter(this.currency, [this.rates]);

  final CurrencyInfo currency;
  final Map<String, double>? rates;

  double _convert(double amount) {
    if (currency.code == CurrencyConfig.baseCurrencyCode) return amount;
    final r = rates?[currency.code];
    if (r == null) return amount;
    return amount * r;
  }

  String format(double amount) {
    final converted = _convert(amount);
    return CurrencyConfig.formatAmount(converted, currency);
  }

  String formatWithDetails(double amount, [String? localizedName]) {
    final converted = _convert(amount);
    final formatted = CurrencyConfig.formatAmount(converted, currency);
    return '$formatted ${localizedName ?? currency.name}';
  }

  String formatCompact(double amount) {
    final converted = _convert(amount);
    if (converted >= 1000000) {
      final val = '${(converted / 1000000).toStringAsFixed(1)}M';
      return _isSymbolAfter(currency) ? '$val ${currency.symbol}' : '${currency.symbol}$val';
    } else if (converted >= 1000) {
      final val = '${(converted / 1000).toStringAsFixed(1)}K';
      return _isSymbolAfter(currency) ? '$val ${currency.symbol}' : '${currency.symbol}$val';
    }
    return format(amount);
  }

  bool _isSymbolAfter(CurrencyInfo c) =>
      c.code == 'XOF' || c.code == 'XAF' || c.code == 'GNF';

  double convert(double amount, CurrencyInfo toCurrency) {
    if (currency == toCurrency) return amount;
    final baseRates = rates;
    if (baseRates == null) return amount;
    final toRate = baseRates[toCurrency.code];
    if (toRate == null) return amount;
    return amount * toRate;
  }

  String formatConverted(double amount, CurrencyInfo toCurrency) {
    final converted = convert(amount, toCurrency);
    return CurrencyConfig.formatAmount(converted, toCurrency);
  }
}
