// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://meal-db-sandy.vercel.app';

  // IMPORTANT: Replace this with your own GUID from https://www.guidgenerator.com/
  static const String dbName = 'f02bf7bc-fa63-477e-b9a2-3b9c28310f94';

  static const Map<String, String> apiHeaders = {
    'X-DB-NAME': dbName,
    'Content-Type': 'application/json',
  };

  // Endpoints
  static const String mealsEndpoint = '/meals';
  static const String categoriesEndpoint = '/categories';

  // DB
  static const String dbFileName = 'recipe_finder.db';
  static const int dbVersion = 1;
  static const String favouritesTable = 'favourites';

  // Prefs
  static const String onboardingKey = 'onboarding_done';

  // Pagination
  static const int pageLimit = 10;
}
