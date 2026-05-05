// lib/data/datasources/meal_api_datasource.dart

import 'package:dio/dio.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../../core/constants/app_constants.dart';

class MealApiDatasource {
  late final Dio _dio;

  MealApiDatasource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: AppConstants.apiHeaders,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
  }

  // Fetch all meals (supports filtering)
  Future<List<Meal>> getMeals({
    String? category,
    String? area,
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (area != null) queryParams['area'] = area;
    if (limit != null) queryParams['_limit'] = limit;
    if (page != null) queryParams['_page'] = page;

    final response = await _dio.get(
      AppConstants.mealsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['meals'] ?? []);

    return data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Fetch single meal by id
  Future<Meal?> getMealById(String id) async {
    final response = await _dio.get('${AppConstants.mealsEndpoint}/$id');
    if (response.data == null) return null;
    final data = response.data is Map ? response.data : null;
    if (data == null) return null;
    return Meal.fromJson(data as Map<String, dynamic>);
  }

  // Popular meals (first page, sorted by name)
  Future<List<Meal>> getPopularMeals({int limit = 10}) async {
    final response = await _dio.get(
      AppConstants.mealsEndpoint,
      queryParameters: {'_limit': limit, '_sort': 'meal', '_order': 'asc'},
    );
    final List<dynamic> data =
        response.data is List ? response.data : (response.data['meals'] ?? []);
    return data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Random meal (fetch all and pick random)
  Future<Meal?> getRandomMeal() async {
    final response = await _dio.get(AppConstants.mealsEndpoint);
    final List<dynamic> data =
        response.data is List ? response.data : (response.data['meals'] ?? []);
    if (data.isEmpty) return null;
    data.shuffle();
    return Meal.fromJson(data.first as Map<String, dynamic>);
  }

  // Fetch categories
  Future<List<MealCategory>> getCategories() async {
    final response = await _dio.get(AppConstants.categoriesEndpoint);
    final List<dynamic> data =
        response.data is List ? response.data : (response.data['categories'] ?? []);
    return data
        .map((e) => MealCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Get distinct areas from meals
  Future<List<String>> getAreas() async {
    final meals = await getMeals(limit: 100);
    final areas = meals
        .map((m) => m.area)
        .where((a) => a != null && a.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    areas.sort();
    return areas;
  }

  // Search meals by name
  Future<List<Meal>> searchMeals(String query) async {
    final response = await _dio.get(
      AppConstants.mealsEndpoint,
      queryParameters: {'meal_like': query},
    );
    final List<dynamic> data =
        response.data is List ? response.data : (response.data['meals'] ?? []);
    return data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
  }
}
