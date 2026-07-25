// config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _url = 'https://mylagtmlapwcunxrvkgo.supabase.co';
  static const String _anonKey = 'sb_publishable_dbVbxueISiVKvQHUcFRMZA_UDu9VUx1';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}