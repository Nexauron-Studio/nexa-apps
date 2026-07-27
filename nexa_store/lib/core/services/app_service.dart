import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexa_store/core/models/app_model.dart';

class AppService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AppModel>> fetchApps() async {
    final response = await _client.from('apps').select();
    // تم إزالة (as List) الزائدة
    return response
        .map((e) => AppModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // (سنضيف هذه الدالة الآن لجلب تطبيق واحد)
  Future<AppModel?> fetchAppById(String id) async {
    final response = await _client.from('apps').select().eq('id', id).single();
    return AppModel.fromJson(response as Map<String, dynamic>);
  }
}
