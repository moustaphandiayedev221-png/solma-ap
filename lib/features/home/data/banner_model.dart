import 'package:flutter/material.dart';

/// Modèle bannière (aligné sur la table Supabase banners)
class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.accentText,
    this.accentValue,
    this.ctaText = 'Shop Now',
    this.gradientStart,
    this.gradientEnd,
    this.watermark,
    this.tagline,
    this.accentColor,
    this.shoeAngle = -0.25,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final String? accentText;
  final String? accentValue;
  final String ctaText;
  final String? gradientStart;
  final String? gradientEnd;
  final String? watermark;
  final String? tagline;
  final String? accentColor;
  final double shoeAngle;
  final int sortOrder;
  final bool isActive;

  List<Color> get gradientColors {
    final start = gradientStart;
    final end = gradientEnd;
    if (start != null && end != null) {
      return [
        _parseColor(start),
        _parseColor(end),
      ];
    }
    return [
      const Color(0xFF1E3A5F),
      const Color(0xFF0D253F),
    ];
  }

  Color get accentColorParsed {
    if (accentColor != null) return _parseColor(accentColor!);
    return const Color(0xFFD4956A);
  }

  static Color _parseColor(String hex) {
    String h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      linkUrl: json['link_url'] as String?,
      accentText: json['accent_text'] as String?,
      accentValue: json['accent_value'] as String?,
      ctaText: json['cta_text'] as String? ?? 'Shop Now',
      gradientStart: json['gradient_start'] as String?,
      gradientEnd: json['gradient_end'] as String?,
      watermark: json['watermark'] as String?,
      tagline: json['tagline'] as String?,
      accentColor: json['accent_color'] as String?,
      shoeAngle: (json['shoe_angle'] as num?)?.toDouble() ?? -0.25,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
