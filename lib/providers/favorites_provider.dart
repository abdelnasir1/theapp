import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<Video> _favoriteVideos = [];
  static const String _favoritesKey = 'favorite_videos';

  FavoritesProvider() {
    _loadFavorites();
  }

  List<Video> get favoriteVideos => _favoriteVideos;

  bool isFavorite(String videoId) {
    return _favoriteVideos.any((v) => v.id == videoId);
  }

  Future<void> toggleFavorite(Video video) async {
    final index = _favoriteVideos.indexWhere((v) => v.id == video.id);
    if (index >= 0) {
      _favoriteVideos.removeAt(index);
    } else {
      _favoriteVideos.add(video);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      _favoriteVideos = decoded.map((item) => Video.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _favoriteVideos.map((v) => v.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, encoded);
  }
}
