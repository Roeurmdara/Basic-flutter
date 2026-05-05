// lib/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/meal_api_datasource.dart';
import '../data/datasources/local_db_datasource.dart';
import '../data/repositories/meal_repository.dart';

// Datasource providers
final mealApiDatasourceProvider = Provider<MealApiDatasource>((ref) {
  return MealApiDatasource();
});

final localDbDatasourceProvider = Provider<LocalDbDatasource>((ref) {
  return LocalDbDatasource();
});

// Repository provider
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final api = ref.watch(mealApiDatasourceProvider);
  final db = ref.watch(localDbDatasourceProvider);
  return MealRepository(api, db);
});
