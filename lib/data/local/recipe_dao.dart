import 'package:sqflite/sqflite.dart';

import '../../models/recipe.dart';
import 'app_database.dart';

class RecipeDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await _db;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await _db;
    final result = await db.query(
      'recipes',
      orderBy: 'id DESC',
    );

    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await _db;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await _db;

    await db.delete(
      'recent_views',
      where: 'recipeId = ?',
      whereArgs: [id],
    );

    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markRecipeAsViewed(int recipeId) async {
    final db = await _db;

    await db.insert(
      'recent_views',
      {
        'recipeId': recipeId,
        'viewedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getRecentViewedRecipes({int limit = 5}) async {
    final db = await _db;

    final result = await db.rawQuery('''
      SELECT r.*
      FROM recent_views rv
      INNER JOIN recipes r ON r.id = rv.recipeId
      ORDER BY rv.viewedAt DESC
      LIMIT ?
    ''', [limit]);

    return result.map((map) => Recipe.fromMap(map)).toList();
  }
}