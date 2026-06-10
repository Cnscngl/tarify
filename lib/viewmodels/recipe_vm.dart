import 'package:flutter/material.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/recipe.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();

  List<Recipe> _recipes = [];
  List<Recipe> _recentViewedRecipes = [];

  bool _isLoading = false;
  String _searchQuery = '';
  bool _showOnlyFavorites = false;
  String _selectedCategory = 'Tümü';
  String _selectedDifficulty = 'Tümü';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get selectedCategory => _selectedCategory;
  String get selectedDifficulty => _selectedDifficulty;
  List<Recipe> get recentViewedRecipes => _recentViewedRecipes;

  List<String> get categories {
    final categorySet = <String>{'Tümü'};
    for (final recipe in _recipes) {
      if (recipe.category.trim().isNotEmpty) {
        categorySet.add(recipe.category.trim());
      }
    }
    return categorySet.toList();
  }

  List<String> get difficulties => const ['Tümü', 'Kolay', 'Orta', 'Zor'];

  List<Recipe> get recipes {
    List<Recipe> filtered = List.from(_recipes);

    if (_showOnlyFavorites) {
      filtered = filtered.where((recipe) => recipe.isFavorite == 1).toList();
    }

    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((recipe) => recipe.category.trim() == _selectedCategory)
          .toList();
    }

    if (_selectedDifficulty != 'Tümü') {
      filtered = filtered
          .where((recipe) => recipe.difficulty.trim() == _selectedDifficulty)
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();

      filtered = filtered.where((recipe) {
        return recipe.title.toLowerCase().contains(query) ||
            recipe.category.toLowerCase().contains(query) ||
            recipe.difficulty.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    _recipes = await _repository.getAllRecipes();
    _recentViewedRecipes = await _repository.getRecentViewedRecipes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _repository.addRecipe(recipe);
    await loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _repository.updateRecipe(recipe);
    await loadRecipes();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final updated = recipe.copyWith(
      isFavorite: recipe.isFavorite == 1 ? 0 : 1,
    );
    await _repository.updateRecipe(updated);
    await loadRecipes();
  }

  Future<void> deleteRecipe(int id) async {
    await _repository.deleteRecipe(id);
    await loadRecipes();
  }

  Future<void> markRecipeAsViewed(int recipeId) async {
    await _repository.markRecipeAsViewed(recipeId);
    _recentViewedRecipes = await _repository.getRecentViewedRecipes();
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void toggleOnlyFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setSelectedDifficulty(String value) {
    _selectedDifficulty = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _showOnlyFavorites = false;
    _selectedCategory = 'Tümü';
    _selectedDifficulty = 'Tümü';
    notifyListeners();
  }
}