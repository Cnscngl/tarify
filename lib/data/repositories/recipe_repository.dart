import '../../models/recipe.dart';
import '../local/recipe_dao.dart';

class RecipeRepository {
  final RecipeDao _dao = RecipeDao();

  Future<List<Recipe>> getAllRecipes() async {
    return await _dao.getAllRecipes();
  }

  Future<int> addRecipe(Recipe recipe) async {
    return await _dao.insertRecipe(recipe);
  }

  Future<int> updateRecipe(Recipe recipe) async {
    return await _dao.updateRecipe(recipe);
  }

  Future<int> deleteRecipe(int id) async {
    return await _dao.deleteRecipe(id);
  }

  Future<void> markRecipeAsViewed(int recipeId) async {
    await _dao.markRecipeAsViewed(recipeId);
  }

  Future<List<Recipe>> getRecentViewedRecipes({int limit = 5}) async {
    return await _dao.getRecentViewedRecipes(limit: limit);
  }
}