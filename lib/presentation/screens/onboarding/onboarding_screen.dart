// lib/presentation/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}

const _pages = [
  _OnboardPage(
    emoji: '🍳',
    title: 'Discover Amazing\nRecipes',
    subtitle: 'Explore thousands of delicious meals from cuisines around the world.',
    bgColor: Color(0xFFFFF3EE),
    accentColor: AppTheme.primary,
  ),
  _OnboardPage(
    emoji: '🌍',
    title: 'Explore Global\nCuisines',
    subtitle: 'From Italian pasta to Japanese ramen — find your next favorite dish.',
    bgColor: Color(0xFFEEFAF8),
    accentColor: AppTheme.secondary,
  ),
  _OnboardPage(
    emoji: '❤️',
    title: 'Save Your\nFavourites',
    subtitle: 'Bookmark the meals you love. Your collection is saved offline, always available.',
    bgColor: Color(0xFFFFF8EE),
    accentColor: AppTheme.accent,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardPageWidget(page: _pages[i]),
              ),
            ),

            // Dots & button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentPage].accentColor,
                      dotColor: _pages[_currentPage].accentColor.withOpacity(0.3),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].accentColor,
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finish();
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Continue'
                            : "Let's Cook!",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageWidget extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: page.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ).animate().scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
