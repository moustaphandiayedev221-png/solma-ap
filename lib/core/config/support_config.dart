/// Configuration du support client SOLMA.
/// Mettez à jour [phone] avec votre numéro réel (format international sans +).
class SupportConfig {
  SupportConfig._();

  /// Email de support
  static const String email = 'support@colways.com';

  /// Numéro de téléphone (format international sans +)
  static const String phone = '221779239305';

  /// Numéro WhatsApp (même format que phone)
  static String get whatsAppNumber => phone;
}
