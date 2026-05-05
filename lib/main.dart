// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    const ProviderScope(
      child: RecipeFinderApp(),
    ),
  );
}

class RecipeFinderApp extends StatefulWidget {
  const RecipeFinderApp({super.key});

  @override
  State<RecipeFinderApp> createState() => _RecipeFinderAppState();
}

class _RecipeFinderAppState extends State<RecipeFinderApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe Finder',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
