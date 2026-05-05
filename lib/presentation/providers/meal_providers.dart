// lib/presentation/providers/meal_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meal.dart';
import '../../data/models/category.dart';
import '../../di/providers.dart';

// ─── Popular Meals ───────────────────────────────────────────────────────────
final popularMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getPopularMeals(limit: 12);
});

// ─── Random Meal ─────────────────────────────────────────────────────────────
final randomMealProvider = FutureProvider<Meal?>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getRandomMeal();
});

// ─── Categories ──────────────────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<MealCategory>>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getCategories();
});

// ─── Areas ───────────────────────────────────────────────────────────────────
final areasProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getAreas();
});

// ─── Selected Category (Explore) ─────────────────────────────────────────────
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ─── Meals by Category ───────────────────────────────────────────────────────
final mealsByCategoryProvider =
    FutureProvider.family<List<Meal>, String>((ref, category) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealsByCategory(category);
});

// ─── Meals by Area ───────────────────────────────────────────────────────────
final mealsByAreaProvider =
    FutureProvider.family<List<Meal>, String>((ref, area) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealsByArea(area);
});

// ─── Meal Detail ─────────────────────────────────────────────────────────────
final mealDetailProvider =
    FutureProvider.family<Meal?, String>((ref, id) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getMealById(id);
});

// ─── Search ──────────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Meal>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(mealRepositoryProvider);
  return repo.searchMeals(query.trim());
});

// ─── Favourites ──────────────────────────────────────────────────────────────
class FavouritesNotifier extends AsyncNotifier<List<Meal>> {
  @override
  Future<List<Meal>> build() async {
    return _fetchFavourites();
  }

  Future<List<Meal>> _fetchFavourites() {
    return ref.read(mealRepositoryProvider).getFavourites();
  }

  Future<void> toggle(Meal meal) async {
    final repo = ref.read(mealRepositoryProvider);
    await repo.toggleFavourite(meal);
    ref.invalidateSelf();
  }

  Future<bool> isFavourite(String id) {
    return ref.read(mealRepositoryProvider).isFavourite(id);
  }
}

final favouritesProvider =
    AsyncNotifierProvider<FavouritesNotifier, List<Meal>>(
        FavouritesNotifier.new);

// ─── Explore filtered meals ──────────────────────────────────────────────────
final exploreMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(mealRepositoryProvider);
  if (category == null) {
    return repo.getPopularMeals(limit: 20);
  }
  return repo.getMealsByCategory(category);
});
