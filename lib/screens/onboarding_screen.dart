import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/user_preferences_model.dart';
import '../providers/data_providers.dart';
import '../core/theme/app_spacing.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  // Selections
  String? _selectedGoal;
  String? _selectedTool;
  final List<String> _selectedCategories = [];
  String? _selectedOutput;

  // Data with icons and colors
  final List<Map<String, dynamic>> _goals = [
    {'label': 'Content Creation', 'icon': LucideIcons.penTool, 'color': const Color(0xFF8B5CF6)},
    {'label': 'Coding & Tech', 'icon': LucideIcons.code, 'color': const Color(0xFF3B82F6)},
    {'label': 'Marketing & Sales', 'icon': LucideIcons.megaphone, 'color': const Color(0xFFF59E0B)},
    {'label': 'Image Art', 'icon': LucideIcons.image, 'color': const Color(0xFFEC4899)},
    {'label': 'Productivity', 'icon': LucideIcons.zap, 'color': const Color(0xFF10B981)},
    {'label': 'Business', 'icon': LucideIcons.briefcase, 'color': const Color(0xFF06B6D4)},
  ];

  final List<Map<String, dynamic>> _tools = [
    {'label': 'ChatGPT', 'icon': LucideIcons.messageCircle, 'color': const Color(0xFF10A37F)},
    {'label': 'Gemini', 'icon': LucideIcons.sparkles, 'color': const Color(0xFF4285F4)},
    {'label': 'Midjourney', 'icon': LucideIcons.image, 'color': const Color(0xFF7C3AED)},
    {'label': 'Claude', 'icon': LucideIcons.bot, 'color': const Color(0xFFD97706)},
    {'label': 'DeepSeek', 'icon': LucideIcons.brain, 'color': const Color(0xFF0EA5E9)},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Social Media', 'icon': LucideIcons.share2, 'color': const Color(0xFFEC4899)},
    {'label': 'Copywriting', 'icon': LucideIcons.type, 'color': const Color(0xFF8B5CF6)},
    {'label': 'Coding', 'icon': LucideIcons.code2, 'color': const Color(0xFF3B82F6)},
    {'label': 'Midjourney Art', 'icon': LucideIcons.palette, 'color': const Color(0xFF7C3AED)},
    {'label': 'SEO', 'icon': LucideIcons.search, 'color': const Color(0xFFF59E0B)},
    {'label': 'Email Marketing', 'icon': LucideIcons.mail, 'color': const Color(0xFF10B981)},
  ];

  final List<Map<String, dynamic>> _outputs = [
    {'label': 'Short prompt', 'icon': LucideIcons.zap, 'color': const Color(0xFFF59E0B), 'desc': 'Quick & punchy'},
    {'label': 'Pro prompt', 'icon': LucideIcons.star, 'color': const Color(0xFF8B5CF6), 'desc': 'Advanced & detailed'},
    {'label': 'Viral prompt', 'icon': LucideIcons.trendingUp, 'color': const Color(0xFFEC4899), 'desc': 'High engagement'},
    {'label': 'Editable template', 'icon': LucideIcons.fileEdit, 'color': const Color(0xFF10B981), 'desc': 'Customizable'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final prefs = UserPreferencesModel(
      selectedGoal: _selectedGoal,
      selectedTool: _selectedTool,
      selectedCategories: _selectedCategories,
      outputPreference: _selectedOutput,
    );

    await ref.read(userPreferencesProvider.notifier).savePreferences(prefs);

    final storage = ref.read(localStorageProvider);
    await storage?.setHasSeenOnboarding(true);

    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Base dark background
          Container(color: const Color(0xFF0F172A)),
          // Animated gradient orbs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 6.seconds, begin: const Offset(1, 1), end: const Offset(1.25, 1.25)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 6,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${_currentPage + 1}/6',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? color : Colors.white.withValues(alpha: 0.7), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, color: color, size: 20)
                  .animate()
                  .scale(duration: 200.ms, begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(LucideIcons.sparkles, size: 64, color: Colors.white),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 40),
        const Text(
          'Find AI prompts\nmade for your style.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Text(
          'Tailored AI prompts for your daily workflow.\nLet\'s personalize your experience.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.clock, size: 16, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Takes less than 1 minute',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 400.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildGoalSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your main goal?',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'Select one use-case to personalize your feed',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
        ).animate().fade(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: 28),
        ..._goals.map((goal) {
          final isSelected = _selectedGoal == goal['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSelectionCard(
              label: goal['label'],
              icon: goal['icon'],
              color: goal['color'],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedGoal = goal['label']),
            ).animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildToolSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which AI do you use?',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'Select your primary AI tool',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
        ).animate().fade(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: 28),
        ..._tools.map((tool) {
          final isSelected = _selectedTool == tool['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSelectionCard(
              label: tool['label'],
              icon: tool['icon'],
              color: tool['color'],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedTool = tool['label']),
            ).animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildCategorySelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What topics interest you?',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'Select one or more categories',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
        ).animate().fade(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: 28),
        ..._categories.map((cat) {
          final isSelected = _selectedCategories.contains(cat['label']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSelectionCard(
              label: cat['label'],
              icon: cat['icon'],
              color: cat['color'],
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(cat['label']);
                  } else {
                    _selectedCategories.add(cat['label']);
                  }
                });
              },
            ).animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildOutputSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred output format?',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'How do you like your prompts?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
        ).animate().fade(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: 28),
        ..._outputs.map((out) {
          final isSelected = _selectedOutput == out['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSelectionCard(
              label: out['label'],
              icon: out['icon'],
              color: out['color'],
              subtitle: out['desc'],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedOutput = out['label']),
            ).animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(LucideIcons.check, size: 48, color: Colors.white),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        const Text(
          'You\'re all set! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          'We\'ve prepared your personalized feed\nbased on your preferences.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fade(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 18, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    'Your First Prompt',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Act as a professional writer. Write a compelling summary of...',
                style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isFinishing ? null : _finishOnboarding,
            icon: _isFinishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(LucideIcons.rocket, size: 20),
            label: Text(
              _isFinishing ? 'Setting up...' : 'Start Exploring',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ).animate(delay: 500.ms).fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canGoNext = true;
    if (_currentPage == 1 && _selectedGoal == null) canGoNext = false;
    if (_currentPage == 2 && _selectedTool == null) canGoNext = false;
    if (_currentPage == 3 && _selectedCategories.isEmpty) canGoNext = false;
    if (_currentPage == 4 && _selectedOutput == null) canGoNext = false;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
                        )
                      else
                        const SizedBox(width: 48),
                      if (_currentPage < 5)
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                if (_currentPage < 5) _buildProgressBar(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildWelcomeStep()),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildGoalSelectionStep(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildToolSelectionStep(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildCategorySelectionStep(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildOutputSelectionStep(),
                      ),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildSuccessStep()),
                    ],
                  ),
                ),
                if (_currentPage < 5)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.white.withValues(alpha: 0.2),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: canGoNext ? _nextPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == 0 ? 'Get Started' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowRight, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}