import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service de taux de change en temps réel.
/// Utilise exchangerate-api.com (gratuit, sans clé API, ~150 devises dont GNF).
/// Cache les taux 24h pour respecter les limites de requêtes.
class ExchangeRateService {
  ExchangeRateService._();
  static final ExchangeRateService _instance = ExchangeRateService._();
  static ExchangeRateService get instance => _instance;

  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _cacheKey = 'exchange_rates_cache';
  static const String _cacheTimeKey = 'exchange_rates_cache_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  Map<String, double>? _cachedRates;
  DateTime? _cacheTime;
  String _lastBase = 'XOF';

  /// Devise de base des prix dans l'app (XOF)
  static const String baseCurrency = 'XOF';

  /// Récupère les taux par rapport à [base] (défaut: XOF).
  /// Retourne un map code -> taux (ex: {'USD': 0.00177, 'GNF': 15.46}).
  Future<Map<String, double>> getRates({String base = baseCurrency}) async {
    if (_cachedRates != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration &&
        _lastBase == base) {
      return _cachedRates!;
    }

    try {
      final fromPrefs = await _loadFromPrefs(base);
      if (fromPrefs != null) return fromPrefs;

      final uri = Uri.parse('$_baseUrl/$base');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('', 408),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['rates'] as Map<String, dynamic>?;
        if (data != null) {
          final rates = <String, double>{};
          for (final e in data.entries) {
            final v = e.value;
            if (v is num) rates[e.key] = v.toDouble();
          }
          _cachedRates = rates;
          _cacheTime = DateTime.now();
          _lastBase = base;
          await _saveToPrefs(rates, base);
          return rates;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('ExchangeRateService error: $e');
    }

    return _cachedRates ?? _fallbackRates(base);
  }

  Future<Map<String, double>?> _loadFromPrefs(String base) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final time = prefs.getInt(_cacheTimeKey);
      if (time == null) return null;
      if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(time)) >
          _cacheDuration) {
        return null;
      }
      final stored = prefs.getString(_cacheKey);
      final storedBase = prefs.getString('${_cacheKey}_base');
      if (stored == null || storedBase != base) return null;
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(
            k,
            v is num ? v.toDouble() : 0.0,
          ));
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToPrefs(Map<String, double> rates, String base) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rates));
      await prefs.setString('${_cacheKey}_base', base);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Taux de repli si l'API est indisponible (XOF, USD, EUR, GNF approximatifs)
  Map<String, double> _fallbackRates(String base) {
    const xofBase = <String, double>{
      'XOF': 1,
      'USD': 0.00152,
      'EUR': 0.00152,
      'GNF': 15.0,
      'XAF': 1,
      'GBP': 0.00132,
      'CHF': 0.00138,
      'CAD': 0.00241,
      'JPY': 0.28,
      'CNY': 0.0122,
      'NGN': 2.43,
      'MAD': 0.0165,
      'TND': 0.00516,
      'DZD': 0.231,
    };
    if (base == 'XOF') return xofBase;
    return {base: 1};
  }

  /// Convertit [amount] de [from] vers [to].
  Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rates = await getRates(base: from);
    final toRate = rates[to];
    if (toRate == null) return amount;
    return amount * toRate;
  }

  /// Récupère le taux from -> to (combien de [to] pour 1 [from]).
  Future<double?> getRate(String from, String to) async {
    if (from == to) return 1;
    final rates = await getRates(base: from);
    return rates[to];
  }

  /// Invalide le cache pour forcer un rafraîchissement.
  void invalidateCache() {
    _cachedRates = null;
    _cacheTime = null;
  }
}
