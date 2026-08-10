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
  
  // Selections
  String? _selectedGoal;
  String? _selectedTool;
  final List<String> _selectedCategories = [];
  String? _selectedOutput;

  final List<String> _goals = [
    'Content Creation', 'Coding & Tech', 'Marketing & Sales', 
    'Image Art', 'Productivity', 'Business'
  ];
  final List<String> _tools = [
    'ChatGPT', 'Gemini', 'Midjourney', 'Claude', 'DeepSeek'
  ];
  final List<String> _categories = [
    'Social Media', 'Copywriting', 'Coding', 'Midjourney Art', 
    'SEO', 'Email Marketing'
  ];
  final List<String> _outputs = [
    'Short prompt', 'Pro prompt', 'Viral prompt', 'Editable template'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: _finishOnboarding,
        child: Text(
          'Skip',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.sparkles, size: 80, color: const Color(0xFF8B5CF6)).animate().scale(duration: 500.ms),
        const SizedBox(height: 40),
        const Text(
          'Find AI prompts\nmade for your style.',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
          textAlign: TextAlign.center,
        ).animate().fade().slideY(begin: 0.2),
        const SizedBox(height: 16),
        Text(
          'Tailored AI prompts for your daily workflow.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
          textAlign: TextAlign.center,
        ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildGoalSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What is your main goal?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select one use-case', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _goals.map((goal) {
            final isSelected = _selectedGoal == goal;
            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(goal, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToolSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Which AI do you use?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select your primary tool', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _tools.map((tool) {
            final isSelected = _selectedTool == tool;
            return GestureDetector(
              onTap: () => setState(() => _selectedTool = tool),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10A37F) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF10A37F) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(tool, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What topics interest you?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select one or more categories', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(cat);
                  } else {
                    _selectedCategories.add(cat);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOutputSelectionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred output format?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Column(
          children: _outputs.map((out) {
            final isSelected = _selectedOutput == out;
            return GestureDetector(
              onTap: () => setState(() => _selectedOutput = out),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEC4899) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFFEC4899) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(out, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.checkCircle, size: 80, color: const Color(0xFF10B981)).animate().scale(duration: 500.ms),
        const SizedBox(height: 40),
        const Text(
          'We prepared your feed!',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
          textAlign: TextAlign.center,
        ).animate().fade().slideY(begin: 0.2),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your First Prompt', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
              const SizedBox(height: 12),
              const Text(
                'Act as a professional writer. Write a compelling summary of...',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _finishOnboarding,
                  icon: const Icon(LucideIcons.copy, size: 18),
                  label: const Text('Copy & Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: 500.ms).fade().slideY(begin: 0.2),
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
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _currentPage < 5 ? _buildSkipButton() : const SizedBox(height: 48),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Force using Next button
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildWelcomeStep()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildGoalSelectionStep()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildToolSelectionStep()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildCategorySelectionStep()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildOutputSelectionStep()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _buildSuccessStep()),
                  ],
                ),
              ),
              if (_currentPage < 5)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index 
                                  ? Colors.white 
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
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
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
