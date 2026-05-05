// lib/presentation/screens/home/home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/meal.dart';
import '../../providers/meal_providers.dart';
import '../../widgets/meal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _RandomMealBanner(ref: ref),
                const SizedBox(height: 28),
                _PopularMealsSection(ref: ref),
                const SizedBox(height: 28),
                _CategoriesSection(ref: ref),
                const SizedBox(height: 28),
                _AreasSection(ref: ref),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()}! 👨‍🍳',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'What shall we cook?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ─── Random Meal Banner ──────────────────────────────────────────────────────

class _RandomMealBanner extends ConsumerWidget {
  final WidgetRef ref;
  const _RandomMealBanner({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(randomMealProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'Surprise Pick',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => ref.refresh(randomMealProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Shuffle'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        async.when(
          loading: () => _shimmerBanner(),
          error: (e, _) => const SizedBox.shrink(),
          data: (meal) => meal == null
              ? const SizedBox.shrink()
              : _RandomMealCard(meal: meal),
        ),
      ],
    );
  }

  Widget _shimmerBanner() => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
}

class _RandomMealCard extends ConsumerWidget {
  final Meal meal;
  const _RandomMealCard({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/meal/${meal.id}',
          extra: {'heroTag': 'random_${meal.id}'}),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Hero(
              tag: 'random_${meal.id}',
              child: meal.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: meal.thumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.divider),
                    )
                  : Container(color: AppTheme.divider),
            ),
            // Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (meal.area != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meal.area!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          meal.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Fav button
                  GestureDetector(
                    onTap: () =>
                        ref.read(favouritesProvider.notifier).toggle(meal),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        meal.isFavourite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: meal.isFavourite
                            ? AppTheme.primary
                            : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

// ─── Popular Meals ───────────────────────────────────────────────────────────

class _PopularMealsSection extends ConsumerWidget {
  final WidgetRef ref;
  const _PopularMealsSection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularMealsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🔥 Popular Meals',
          actionLabel: 'See all',
          onAction: () => context.push('/meals',
              extra: {'title': 'Popular Meals'}),
        ),
        const SizedBox(height: 16),
        async.when(
          loading: () => SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          error: (e, _) => ErrorStateWidget(
            message: 'Could not load meals',
            onRetry: () => ref.refresh(popularMealsProvider),
          ),
          data: (meals) => SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: meals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => SizedBox(
                width: 165,
                child: MealCard(meal: meals[i], isCompact: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Categories ──────────────────────────────────────────────────────────────

class _CategoriesSection extends ConsumerWidget {
  final WidgetRef ref;
  const _CategoriesSection({required this.ref});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🗂 Categories',
          actionLabel: 'Explore',
          onAction: () => context.go('/explore'),
        ),
        const SizedBox(height: 14),
        async.when(
          loading: () => SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (cats) => SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = cats[i];
                final emoji = _categoryEmojis[cat.name] ?? '🍽';
                return GestureDetector(
                  onTap: () => context.push('/meals', extra: {
                    'title': cat.name,
                    'category': cat.name,
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(emoji),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Areas / Cuisines ────────────────────────────────────────────────────────

class _AreasSection extends ConsumerWidget {
  final WidgetRef ref;
  const _AreasSection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(areasProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '🌍 Cuisines'),
        const SizedBox(height: 14),
        async.when(
          loading: () => SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (areas) => SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => AreaCard(
                area: areas[i],
                onTap: () => context.push('/meals', extra: {
                  'title': '${areas[i]} Cuisine',
                  'area': areas[i],
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
