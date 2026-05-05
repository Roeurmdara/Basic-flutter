// lib/presentation/screens/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/meal_providers.dart';
import '../../widgets/meal_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  static const _categoryEmojis = {
    'Beef': '🥩',
    'Chicken': '🍗',
    'Dessert': '🍰',
    'Lamb': '🍖',
    'Miscellaneous': '🍱',
    'Pasta': '🍝',
    'Pork': '🥓',
    'Seafood': '🦐',
    'Side': '🥗',
    'Starter': '🥙',
    'Vegan': '🌱',
    'Vegetarian': '🥦',
    'Breakfast': '🥞',
    'Goat': '🐐',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final mealsAsync = ref.watch(exploreMealsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Explore'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Search meals...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Category filter chips
                categoriesAsync.when(
                  loading: () => const SizedBox(height: 48),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (cats) => SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // "All" chip
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryChip(
                            label: 'All',
                            emoji: '🍽',
                            selected: selectedCategory == null,
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = null,
                          ),
                        ),
                        ...cats.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CategoryChip(
                                label: cat.name,
                                emoji: _categoryEmojis[cat.name] ?? '🍴',
                                selected: selectedCategory == cat.name,
                                onTap: () {
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = cat.name;
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search results or filtered meals
                _buildMealSection(context, ref),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    if (query.isNotEmpty) {
      // Show search results
      final searchAsync = ref.watch(searchResultsProvider);
      return searchAsync.when(
        loading: () => const MealGridShimmer(),
        error: (e, _) =>
            ErrorStateWidget(message: 'Search failed. Please try again.'),
        data: (meals) {
          if (meals.isEmpty) {
            return const EmptyStateWidget(
              emoji: '🔍',
              title: 'No results',
              subtitle: 'Try a different search term',
            );
          }
          return _MealGrid(meals: meals);
        },
      );
    }

    // Show filtered or all meals
    final mealsAsync = ref.watch(exploreMealsProvider);
    return mealsAsync.when(
      loading: () => const MealGridShimmer(),
      error: (e, _) => ErrorStateWidget(
        message: 'Could not load meals',
        onRetry: () => ref.refresh(exploreMealsProvider),
      ),
      data: (meals) {
        if (meals.isEmpty) {
          return const EmptyStateWidget(
            emoji: '🍽',
            title: 'No meals found',
            subtitle: 'Try selecting a different category',
          );
        }
        return _MealGrid(meals: meals);
      },
    );
  }
}

class _MealGrid extends StatelessWidget {
  final List meals;
  const _MealGrid({required this.meals});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: meals.length,
      itemBuilder: (_, i) => MealCard(meal: meals[i]),
    );
  }
}
