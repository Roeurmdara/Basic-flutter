// lib/presentation/screens/favourite/favourite_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/meal.dart';
import '../../providers/meal_providers.dart';
import '../../widgets/meal_card.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favouritesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('My Favourites ❤️'),
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: favAsync.when(
              loading: () => SliverList(
                delegate: SliverChildListDelegate([const MealGridShimmer()]),
              ),
              error: (e, _) => SliverList(
                delegate: SliverChildListDelegate([
                  ErrorStateWidget(
                    message: 'Could not load favourites.',
                    onRetry: () => ref.refresh(favouritesProvider),
                  ),
                ]),
              ),
              data: (meals) {
                if (meals.isEmpty) {
                  return SliverFillRemaining(
                    child: const EmptyStateWidget(
                      emoji: '🫙',
                      title: 'No favourites yet',
                      subtitle:
                          'Tap the heart icon on any recipe to save it here.',
                    ).animate().fadeIn(duration: 500.ms),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      '${meals.length} saved recipe${meals.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ...meals.asMap().entries.map((entry) =>
                        _FavouriteListItem(
                          meal: entry.value,
                          index: entry.key,
                        )),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteListItem extends ConsumerWidget {
  final Meal meal;
  final int index;

  const _FavouriteListItem({required this.meal, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('fav_${meal.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) =>
            ref.read(favouritesProvider.notifier).toggle(meal),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppTheme.error, size: 28),
        ),
        child: GestureDetector(
          onTap: () => context.push('/meal/${meal.id}',
              extra: {'heroTag': 'fav_${meal.id}'}),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Image
                Hero(
                  tag: 'fav_${meal.id}',
                  child: SizedBox(
                    width: 110,
                    child: meal.thumbnail != null
                        ? CachedNetworkImage(
                            imageUrl: meal.thumbnail!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.divider,
                            child: const Icon(Icons.restaurant_menu_rounded,
                                color: AppTheme.textSecondary),
                          ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          meal.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (meal.category != null) ...[
                              Icon(Icons.local_dining_rounded,
                                  size: 12, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                meal.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 11),
                              ),
                            ],
                            if (meal.area != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.place_rounded,
                                  size: 12, color: AppTheme.secondary),
                              const SizedBox(width: 2),
                              Text(
                                meal.area!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (meal.ingredients.isNotEmpty)
                          Text(
                            '${meal.ingredients.length} ingredients',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Remove button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () =>
                        ref.read(favouritesProvider.notifier).toggle(meal),
                    icon: const Icon(Icons.favorite_rounded,
                        color: AppTheme.primary, size: 22),
                  ),
                ),
              ],
            ),
          ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(
                begin: 0.1,
                end: 0,
              ),
        ),
      ),
    );
  }
}
