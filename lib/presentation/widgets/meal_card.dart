// lib/presentation/widgets/meal_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/meal.dart';
import '../../core/theme/app_theme.dart';
import '../providers/meal_providers.dart';

class MealCard extends ConsumerWidget {
  final Meal meal;
  final bool isCompact;

  const MealCard({
    super.key,
    required this.meal,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = 'meal_${meal.id}';
    return GestureDetector(
      onTap: () => context.push('/meal/${meal.id}', extra: {'heroTag': tag}),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Hero(
              tag: tag,
              child: AspectRatio(
                aspectRatio: isCompact ? 1.2 : 1.4, // Adjusted for better fit
                child: meal.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: meal.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _shimmerBox(),
                        errorWidget: (_, __, ___) => _placeholderBox(),
                      )
                    : _placeholderBox(),
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: isCompact ? 13 : 15,
                            height: 1.2, // Tightens vertical space
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (meal.category != null) ...[
                            Icon(Icons.local_dining_rounded,
                                size: 12, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                meal.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (meal.area != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.place_rounded,
                                size: 12, color: AppTheme.secondary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                meal.area!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    // Use Flexible or a small SizedBox instead of Spacer to avoid overflows
                    const Expanded(child: SizedBox(height: 4)), 
                    Align(
                      alignment: Alignment.centerRight,
                      child: _FavouriteIconButton(meal: meal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox() => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      );

  Widget _placeholderBox() => Container(
        color: AppTheme.divider,
        child: const Center(
          child: Icon(Icons.restaurant_menu_rounded,
              color: AppTheme.textSecondary, size: 40),
        ),
      );
}

class _FavouriteIconButton extends ConsumerWidget {
  final Meal meal;
  const _FavouriteIconButton({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref.read(favouritesProvider.notifier).toggle(meal);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: meal.isFavourite
              ? AppTheme.primary.withOpacity(0.12)
              : Colors.grey.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          meal.isFavourite ? Icons.favorite_rounded : Icons.favorite_outline,
          size: 18,
          color: meal.isFavourite ? AppTheme.primary : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ─── Shimmer List Loader ─────────────────────────────────────────────────────

class MealGridShimmer extends StatelessWidget {
  final int count;
  const MealGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72, // Increased height to prevent overflow
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: count,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            child: Text(actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ─── Category Chip ───────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Area Card ───────────────────────────────────────────────────────────────

class AreaCard extends StatelessWidget {
  final String area;
  final VoidCallback onTap;
  final Map<String, String> _flagMap = const {
    'American': '🇺🇸',
    'British': '🇬🇧',
    'Canadian': '🇨🇦',
    'Chinese': '🇨🇳',
    'Croatian': '🇭🇷',
    'Dutch': '🇳🇱',
    'Egyptian': '🇪🇬',
    'Filipino': '🇵🇭',
    'French': '🇫🇷',
    'Greek': '🇬🇷',
    'Indian': '🇮🇳',
    'Irish': '🇮🇪',
    'Italian': '🇮🇹',
    'Jamaican': '🇯🇲',
    'Japanese': '🇯🇵',
    'Kenyan': '🇰🇪',
    'Malaysian': '🇲🇾',
    'Mexican': '🇲🇽',
    'Moroccan': '🇲🇦',
    'Polish': '🇵🇱',
    'Portuguese': '🇵🇹',
    'Russian': '🇷🇺',
    'Spanish': '🇪🇸',
    'Thai': '🇹🇭',
    'Tunisian': '🇹🇳',
    'Turkish': '🇹🇷',
    'Ukrainian': '🇺🇦',
    'Uruguayan': '🇺🇾',
    'Vietnamese': '🇻🇳',
  };

  const AreaCard({super.key, required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final flag = _flagMap[area] ?? '🌍';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                area,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😢', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty State Widget ──────────────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}