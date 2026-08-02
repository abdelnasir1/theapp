// providers/content_provider.dart
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/supabase_service.dart';

class ContentProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Category> _levelOneCategories = [];
  List<Category> _levelTwoCategories = [];
  List<Category> _levelThreeCategories = [];
  List<Category> _levelFourCategories = [];
  List<Example> _examples = [];
  bool _isLoading = false;

  List<Category> get levelOneCategories => _levelOneCategories;
  List<Category> get levelTwoCategories => _levelTwoCategories;
  List<Category> get levelThreeCategories => _levelThreeCategories;
  List<Category> get levelFourCategories => _levelFourCategories;
  List<Example> get examples => _examples;
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
      _levelTwoCategories =
          await _supabaseService.getCategories(level: 2, parentId: parentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchLevelThreeCategories(String parentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _levelThreeCategories =
          await _supabaseService.getCategories(level: 3, parentId: parentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchLevelFourCategories(String parentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _levelFourCategories =
          await _supabaseService.getCategories(level: 4, parentId: parentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchExamples(String categoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _examples = await _supabaseService.getExamples(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
