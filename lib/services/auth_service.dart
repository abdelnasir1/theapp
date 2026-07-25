// services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      return await getUserProfile(response.user!.id);
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<UserModel> signup(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Signup failed');
      }

      // Create profile
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': name,
      });

      return UserModel(
        id: response.user!.id,
        email: email,
        fullName: name,
        isSubscribed: false,
      );
    } catch (e) {
      throw Exception('Signup error: ${e.toString()}');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return await getUserProfile(user.id);
  }

  Future<UserModel> getUserProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}