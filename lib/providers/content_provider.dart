// providers/content_provider.dart
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/supabase_service.dart';


int compareExampleNames(String a, String b) {
  // Extract year (first 4 digits) and the letter part
  final yearA = int.tryParse(a.substring(0, 4)) ?? 0;
  final yearB = int.tryParse(b.substring(0, 4)) ?? 0;

  // First sort by year (descending: 2026 before 2018)
  if (yearA != yearB) {
    return yearB.compareTo(yearA);
  }

  // Same year → sort by the letter part (A before B)
  final letterA = a.length > 4 ? a.substring(4) : '';
  final letterB = b.length > 4 ? b.substring(4) : '';
  return letterA.compareTo(letterB);
}

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
      _examples.sort((a, b) => compareExampleNames(a.name, b.name));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
