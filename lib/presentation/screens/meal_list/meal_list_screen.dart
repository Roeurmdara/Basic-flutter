// lib/presentation/screens/meal_list/meal_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/meal_providers.dart';
import '../../widgets/meal_card.dart';

class MealListScreen extends ConsumerWidget {
  final String title;
  final String? category;
  final String? area;

  const MealListScreen({
    super.key,
    required this.title,
    this.category,
    this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = category != null
        ? ref.watch(mealsByCategoryProvider(category!))
        : area != null
            ? ref.watch(mealsByAreaProvider(area!))
            : ref.watch(popularMealsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(title),
            floating: true,
            snap: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: mealsAsync.when(
              loading: () => SliverList(
                delegate: SliverChildListDelegate(
                    [const MealGridShimmer(count: 8)]),
              ),
              error: (e, _) => SliverFillRemaining(
                child: ErrorStateWidget(
                  message: 'Could not load meals',
                  onRetry: () {
                    if (category != null) {
                      ref.refresh(mealsByCategoryProvider(category!));
                    } else if (area != null) {
                      ref.refresh(mealsByAreaProvider(area!));
                    } else {
                      ref.refresh(popularMealsProvider);
                    }
                  },
                ),
              ),
              data: (meals) {
                if (meals.isEmpty) {
                  return SliverFillRemaining(
                    child: const EmptyStateWidget(
                      emoji: '🍽',
                      title: 'No meals here',
                      subtitle: 'Check back later!',
                    ),
                  );
                }
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => MealCard(meal: meals[i]),
                    childCount: meals.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
