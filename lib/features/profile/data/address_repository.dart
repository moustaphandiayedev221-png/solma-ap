import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import 'address_model.dart';

class AddressRepository {
  AddressRepository([SupabaseClient? client]) : _client = client ?? supabaseClient;

  final SupabaseClient _client;
  static const String _table = 'addresses';

  Future<List<AddressModel>> getAddresses(String userId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return (res as List)
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel?> getById(String id) async {
    final res = await _client.from(_table).select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return AddressModel.fromJson(res);
  }

  Future<AddressModel> insert(String userId, AddressModel address) async {
    if (address.isDefault) {
      await _client.from(_table).update({'is_default': false}).eq('user_id', userId);
    }
    final res = await _client.from(_table).insert({
      'user_id': userId,
      'label': address.label,
      'full_name': address.fullName,
      'line1': address.line1,
      'line2': address.line2,
      'city': address.city,
      'postal_code': address.postalCode,
      'country': address.country,
      'region': address.region,
      'country_code': address.countryCode,
      'phone': address.phone,
      'is_default': address.isDefault,
    }).select().single();
    return AddressModel.fromJson(res);
  }

  Future<AddressModel> update(AddressModel address) async {
    if (address.isDefault) {
      await _client
          .from(_table)
          .update({'is_default': false})
          .eq('user_id', address.userId)
          .neq('id', address.id);
    }
    final res = await _client.from(_table).update({
      'label': address.label,
      'full_name': address.fullName,
      'line1': address.line1,
      'line2': address.line2,
      'city': address.city,
      'postal_code': address.postalCode,
      'country': address.country,
      'region': address.region,
      'country_code': address.countryCode,
      'phone': address.phone,
      'is_default': address.isDefault,
    }).eq('id', address.id).select().single();
    return AddressModel.fromJson(res);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> setDefault(String userId, String addressId) async {
    await _client.from(_table).update({'is_default': false}).eq('user_id', userId);
    await _client.from(_table).update({'is_default': true}).eq('id', addressId);
  }
}
