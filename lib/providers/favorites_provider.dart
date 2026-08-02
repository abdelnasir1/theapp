import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<Example> _favoriteExamples = [];
  String? _userId;

  List<Example> get favoriteExamples => _favoriteExamples;

  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _loadFavorites();
    }
  }

  String get _favoritesKey => _userId == null ? 'guest_favorites' : 'favorites_$_userId';

  bool isFavorite(String exampleId) {
    return _favoriteExamples.any((v) => v.id == exampleId);
  }

  Future<void> toggleFavorite(Example example) async {
    final index = _favoriteExamples.indexWhere((v) => v.id == example.id);
    if (index >= 0) {
      _favoriteExamples.removeAt(index);
    } else {
      _favoriteExamples.add(example);
    }
    notifyListeners();
    await _saveFavorites();
  }

  void clearLocal() {
    _favoriteExamples = [];
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      _favoriteExamples = decoded.map((item) => Example.fromJson(item)).toList();
    } else {
      _favoriteExamples = [];
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _favoriteExamples.map((v) => v.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, encoded);
  }
}
