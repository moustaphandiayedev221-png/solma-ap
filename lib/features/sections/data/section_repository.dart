import 'package:supabase_flutter/supabase_flutter.dart';

import 'section_model.dart';

class SectionRepository {
  SectionRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;
  static const String _table = 'product_sections';

  Future<List<SectionModel>> getAll() async {
    final res =
        await _client.from(_table).select().order('display_order', ascending: true);
    return (res as List)
        .map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
