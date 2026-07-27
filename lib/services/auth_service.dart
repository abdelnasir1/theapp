// services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ====================== EMAIL / PASSWORD ======================

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

  // ====================== GOOGLE SIGN-IN ======================

  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Optional: add serverClientId if you configured it in Google Cloud
        // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول بجوجل');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('فشل الحصول على Google ID Token');
      }

      // 2. Sign in to Supabase with the Google ID Token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('فشل تسجيل الدخول بجوجل');
      }

      final user = response.user!;

      // 3. Check if profile already exists
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        // First time → Create profile
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
      throw Exception('Google Sign-In error: ${e.toString()}');
    }
  }

  // ====================== COMMON ======================

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
    // Also sign out from Google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    await _supabase.auth.signOut();
  }
}