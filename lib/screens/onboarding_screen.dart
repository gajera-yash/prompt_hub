import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    {
      'icon': LucideIcons.sparkles,
      'title': 'Discover AI Prompts',
      'subtitle': 'Browse thousands of expertly curated prompts for ChatGPT, Midjourney, and more.',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'icon': LucideIcons.copy,
      'title': 'Copy & Use Instantly',
      'subtitle': 'One tap to copy any prompt. Fill the variables and get instant AI results.',
      'color': const Color(0xFF3B82F6),
    },
    {
      'icon': LucideIcons.heart,
      'title': 'Save Your Favorites',
      'subtitle': 'Build your personal collection of go-to prompts to supercharge your workflow.',
      'color': const Color(0xFFEC4899),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Glow
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_pages[_currentPage]['color'] as Color).withValues(alpha: 0.2),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ).animate(target: _currentPage.toDouble())
                 .scale(duration: 400.ms),
              ),
              
              Column(
                children: [
                  // Skip Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, i) {
                        final page = _pages[i];
                        final color = page['color'] as Color;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon Card
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    page['icon'] as IconData,
                                    size: 72,
                                    color: color,
                                  ),
                                ),
                              ).animate(key: ValueKey(i)).scale(duration: 500.ms, curve: Curves.easeOutBack),
                              const SizedBox(height: 56),
                              // Title
                              Text(
                                page['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ).animate(key: ValueKey('t$i')).fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
                              const SizedBox(height: 16),
                              // Subtitle
                              Text(
                                page['subtitle'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ).animate(key: ValueKey('s$i')).fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _pages.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8,
                            activeDotColor: _pages[_currentPage]['color'] as Color,
                            dotColor: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                context.go('/home');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pages[_currentPage]['color'] as Color,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ).animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                         .shimmer(duration: 1.seconds),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
