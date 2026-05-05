// lib/presentation/screens/detail/meal_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/meal.dart';
import '../../providers/meal_providers.dart';
import '../../widgets/meal_card.dart';

class MealDetailScreen extends ConsumerWidget {
  final String mealId;
  final String? heroTag;

  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealDetailProvider(mealId));

    return Scaffold(
      body: mealAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => ErrorStateWidget(
          message: 'Could not load recipe details.',
          onRetry: () => ref.refresh(mealDetailProvider(mealId)),
        ),
        data: (meal) {
          if (meal == null) {
            return const ErrorStateWidget(message: 'Recipe not found.');
          }
          return _MealDetailBody(meal: meal, heroTag: heroTag);
        },
      ),
    );
  }
}

class _MealDetailBody extends ConsumerWidget {
  final Meal meal;
  final String? heroTag;

  const _MealDetailBody({required this.meal, this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favouritesProvider);
    final isFav = favAsync.maybeWhen(
      data: (favs) => favs.any((f) => f.id == meal.id),
      orElse: () => meal.isFavourite,
    );

    return CustomScrollView(
      slivers: [
        // ─── Hero Image App Bar ────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppTheme.surfaceLight,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isFav ? AppTheme.primary : Colors.white,
                ),
                onPressed: () =>
                    ref.read(favouritesProvider.notifier).toggle(meal),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag ?? 'meal_${meal.id}',
                  child: meal.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: meal.thumbnail!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.divider,
                          child: const Icon(Icons.restaurant_menu_rounded,
                              size: 80, color: AppTheme.textSecondary),
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        AppTheme.surfaceLight,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Content ──────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title
              Text(
                meal.name,
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              // Tags row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.category != null)
                    _InfoChip(
                      icon: Icons.local_dining_rounded,
                      label: meal.category!,
                      color: AppTheme.primary,
                    ),
                  if (meal.area != null)
                    _InfoChip(
                      icon: Icons.place_rounded,
                      label: meal.area!,
                      color: AppTheme.secondary,
                    ),
                  if (meal.tags != null && meal.tags!.isNotEmpty)
                    ...meal.tags!
                        .split(',')
                        .where((t) => t.trim().isNotEmpty)
                        .map((tag) => _InfoChip(
                              icon: Icons.label_outline_rounded,
                              label: tag.trim(),
                              color: AppTheme.accent,
                            )),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // ─── Ingredients ──────────────────────────────────────────
              if (meal.ingredients.isNotEmpty) ...[
                _SectionTitle(
                  emoji: '🧂',
                  title: 'Ingredients (${meal.ingredients.length})',
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: meal.ingredients.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ing = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: i < meal.ingredients.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: AppTheme.divider,
                                    width: 1,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ing.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              ing.measure,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),
              ],

              // ─── Instructions ─────────────────────────────────────────
              if (meal.instructions != null &&
                  meal.instructions!.isNotEmpty) ...[
                const _SectionTitle(emoji: '📋', title: 'Instructions'),
                const SizedBox(height: 12),
                _InstructionsWidget(
                    instructions: meal.instructions!),
                const SizedBox(height: 24),
              ],

              // ─── Links ────────────────────────────────────────────────
              if (meal.youtubeUrl != null || meal.sourceUrl != null) ...[
                const _SectionTitle(emoji: '🔗', title: 'More Info'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (meal.youtubeUrl != null &&
                        meal.youtubeUrl!.isNotEmpty)
                      Expanded(
                        child: _LinkButton(
                          icon: Icons.play_circle_rounded,
                          label: 'Watch Video',
                          color: const Color(0xFFFF0000),
                          url: meal.youtubeUrl!,
                        ),
                      ),
                    if (meal.youtubeUrl != null &&
                        meal.youtubeUrl!.isNotEmpty &&
                        meal.sourceUrl != null &&
                        meal.sourceUrl!.isNotEmpty)
                      const SizedBox(width: 12),
                    if (meal.sourceUrl != null &&
                        meal.sourceUrl!.isNotEmpty)
                      Expanded(
                        child: _LinkButton(
                          icon: Icons.open_in_new_rounded,
                          label: 'Original Recipe',
                          color: AppTheme.secondary,
                          url: meal.sourceUrl!,
                        ),
                      ),
                  ],
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionTitle({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _InstructionsWidget extends StatefulWidget {
  final String instructions;
  const _InstructionsWidget({required this.instructions});

  @override
  State<_InstructionsWidget> createState() => _InstructionsWidgetState();
}

class _InstructionsWidgetState extends State<_InstructionsWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final steps = widget.instructions
        .split(RegExp(r'\r?\n\r?\n|\r?\n(?=\d)'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final displaySteps =
        _expanded ? steps : steps.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displaySteps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.trim(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
          if (steps.length > 3)
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? 'Show less'
                    : 'Show ${steps.length - 3} more steps...',
                style: const TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          try {
            await launchUrl(uri);
          } catch (_) {}
        }
      },
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
