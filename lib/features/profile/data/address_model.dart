/// Adresse de livraison (table public.addresses).
class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
    this.label,
    required this.fullName,
    required this.line1,
    this.line2,
    required this.city,
    this.postalCode,
    required this.country,
    this.region,
    this.countryCode,
    this.phone,
    this.isDefault = false,
  });

  final String id;
  final String userId;
  final String? label;
  final String fullName;
  final String line1;
  final String? line2;
  final String city;
  final String? postalCode;
  final String country;
  /// Région/État pour le calcul des frais de livraison.
  final String? region;
  /// Code ISO pays (ex: SN, FR) pour le calcul des frais de livraison.
  final String? countryCode;
  final String? phone;
  final bool isDefault;

  String get singleLine {
    final parts = [line1];
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    parts.add('$postalCode $city'.trim());
    parts.add(country);
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'label': label,
        'full_name': fullName,
        'line1': line1,
        'line2': line2,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'region': region,
        'country_code': countryCode,
        'phone': phone,
        'is_default': isDefault,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String?,
      fullName: json['full_name'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String?,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String,
      region: json['region'] as String?,
      countryCode: json['country_code'] as String?,
      phone: json['phone'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullName,
    String? line1,
    String? line2,
    String? city,
    String? postalCode,
    String? country,
    String? region,
    String? countryCode,
    String? phone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      region: region ?? this.region,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
