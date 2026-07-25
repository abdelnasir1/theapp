// providers/content_provider.dart
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/supabase_service.dart';

class ContentProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Category> _levelOneCategories = [];
  List<Category> _levelTwoCategories = [];
  List<Video> _videos = [];
  bool _isLoading = false;

  List<Category> get levelOneCategories => _levelOneCategories;
  List<Category> get levelTwoCategories => _levelTwoCategories;
  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;

  Future<void> fetchLevelOneCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _levelOneCategories = await _supabaseService.getCategories(level: 1);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchLevelTwoCategories(String parentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _levelTwoCategories = await _supabaseService.getCategories(
        level: 2,
        parentId: parentId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchVideos(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _videos = await _supabaseService.getVideos(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}



