// lib/data/repositories/meal_repository.dart

import '../datasources/meal_api_datasource.dart';
import '../datasources/local_db_datasource.dart';
import '../models/meal.dart';
import '../models/category.dart';

class MealRepository {
  final MealApiDatasource _api;
  final LocalDbDatasource _localDb;

  MealRepository(this._api, this._localDb);

  Future<List<Meal>> getPopularMeals({int limit = 10}) async {
    final meals = await _api.getPopularMeals(limit: limit);
    return _mergeFavourites(meals);
  }

  Future<Meal?> getRandomMeal() async {
    final meal = await _api.getRandomMeal();
    if (meal == null) return null;
    final favIds = await _localDb.getFavouriteIds();
    meal.isFavourite = favIds.contains(meal.id);
    return meal;
  }

  Future<List<MealCategory>> getCategories() => _api.getCategories();

  Future<List<String>> getAreas() => _api.getAreas();

  Future<List<Meal>> getMealsByCategory(String category) async {
    final meals = await _api.getMeals(category: category);
    return _mergeFavourites(meals);
  }

  Future<List<Meal>> getMealsByArea(String area) async {
    final meals = await _api.getMeals(area: area);
    return _mergeFavourites(meals);
  }

  Future<Meal?> getMealById(String id) async {
    final meal = await _api.getMealById(id);
    if (meal == null) return null;
    final favIds = await _localDb.getFavouriteIds();
    meal.isFavourite = favIds.contains(meal.id);
    return meal;
  }

  Future<List<Meal>> searchMeals(String query) async {
    final meals = await _api.searchMeals(query);
    return _mergeFavourites(meals);
  }

  // Favourites
  Future<void> toggleFavourite(Meal meal) async {
    if (await _localDb.isFavourite(meal.id)) {
      await _localDb.removeFavourite(meal.id);
    } else {
      await _localDb.saveFavourite(meal);
    }
  }

  Future<List<Meal>> getFavourites() => _localDb.getFavourites();

  Future<bool> isFavourite(String id) => _localDb.isFavourite(id);

  // Helper to merge favourite status
  Future<List<Meal>> _mergeFavourites(List<Meal> meals) async {
    final favIds = await _localDb.getFavouriteIds();
    return meals.map((m) {
      m.isFavourite = favIds.contains(m.id);
      return m;
    }).toList();
  }
}
