// services/auth_service.dart
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  // Flag to ensure Google Sign-In is only initialized once
  bool _isGoogleInitialized = false;


  Future<UserModel> signInWithGoogle() async {
    try {
      if (!_isGoogleInitialized) {
        await googleSignIn.initialize(
          serverClientId: '362341234733-htfp79eq8f08gaucu8kk10tbci647aus.apps.googleusercontent.com',
        );
        _isGoogleInitialized = true;
      }

      final GoogleSignInAccount? account = await googleSignIn.authenticate();
      
      if (account == null) {
        throw 'الرجاء أختيار حساب قوقل';
      }

      final authentication = await account.authentication;
      final String? idToken = authentication.idToken;

      if (idToken == null) {
        throw 'الرجاء أختيار حساب قوقل';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user == null) {
        throw 'الرجاء أختيار حساب قوقل';
      }

      final user = response.user!;

      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              'User',
        });
      }

      return await getUserProfile(user.id);
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      throw 'الرجاء أختيار حساب قوقل';
    }
  }

  // ====================== COMMON ======================

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return await getUserProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('GetUserProfile error: $e');
      throw 'حدث خطأ في تحميل البيانات.';
    }
  }

  Future<void> logout() async {
    try {
      final user = _supabase.auth.currentUser;
      final provider = user?.appMetadata['provider'] as String?;

      if (provider == 'google') {
        await googleSignIn.signOut();
      }
      await _supabase.auth.signOut();
    } catch (e) {
      await _supabase.auth.signOut();
    }
  }
}
