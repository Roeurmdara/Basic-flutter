// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/favourite/favourite_screen.dart';
import '../../presentation/screens/detail/meal_detail_screen.dart';
import '../../presentation/screens/meal_list/meal_list_screen.dart';
import '../../core/constants/app_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(AppConstants.onboardingKey) ?? false;
      if (done && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (_, __) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/favourite',
            builder: (_, __) => const FavouriteScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/meal/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return MealDetailScreen(mealId: id, heroTag: extra?['heroTag']);
        },
      ),
      GoRoute(
        path: '/meals',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MealListScreen(
            title: extra?['title'] ?? 'Meals',
            category: extra?['category'],
            area: extra?['area'],
          );
        },
      ),
    ],
  );
}

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _tabs = ['/home', '/explore', '/favourite'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              setState(() => _currentIndex = i);
              context.go(_tabs[i]);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Favourites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
