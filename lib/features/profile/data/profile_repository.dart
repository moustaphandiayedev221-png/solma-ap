import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';

/// Profil utilisateur (table public.profiles).
class ProfileModel {
  const ProfileModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final dob = json['date_of_birth'];
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: dob != null ? DateTime.tryParse(dob as String) : null,
    );
  }
}

class ProfileRepository {
  ProfileRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'profiles';

  Future<ProfileModel?> getProfile(String userId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (res == null) return null;
    return ProfileModel.fromJson(res);
  }

  Future<void> updateProfile(
    String userId, {
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (phone != null) updates['phone'] = phone.trim().isEmpty ? null : phone.trim();
    if (dateOfBirth != null) updates['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
    await _client.from(_table).update(updates).eq('id', userId);
  }
}
