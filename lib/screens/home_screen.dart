import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/section_header.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/feature_banner_card.dart';
import '../widgets/skeleton_loading.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  String _selectedCategory = 'All';

  final List<String> _chipCategories = [
    'ChatGPT',
    'Midjourney',
    'SEO Articles',
    'React',
    'YouTube Scripts',
    'Business Plans'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: AppSpacing.lg),
                    CustomSearchBar(
                      onTap: () => context.push('/search'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // AI Tool Model Filter Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          'ChatGPT',
                          'Midjourney',
                          'Gemini',
                          'Claude',
                          'DALL·E',
                          'DeepSeek',
                        ].map((model) {
                          final selectedModel = ref.watch(selectedAIToolFilterProvider);
                          final isSelected = selectedModel == model;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(model),
                              selectedColor: AppColors.primary,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              onSelected: (_) {
                                ref.read(selectedAIToolFilterProvider.notifier).setFilter(model);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Banners
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        FeatureBannerCard(
                          title: 'Master ChatGPT',
                          subtitle: 'Top 100 prompts for writing',
                          icon: LucideIcons.bot,
                          gradientColors: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                          onTryNow: () => context.push('/category/ChatGPT'),
                        ),
                        FeatureBannerCard(
                          title: 'Code Like a Pro',
                          subtitle: 'Boost your dev workflow',
                          icon: LucideIcons.code,
                          gradientColors: const [Color(0xFF00E5FF), Color(0xFF69F0AE)],
                          onTryNow: () => context.push('/category/React'),
                        ),
                        FeatureBannerCard(
                          title: 'Marketing Magic',
                          subtitle: 'Generate high-converting copy',
                          icon: LucideIcons.megaphone,
                          gradientColors: const [Color(0xFFFF6B9D), Color(0xFFFF8A65)],
                          onTryNow: () => context.push('/category/SEO Articles'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.border,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            
            // Prompt Generator Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.push('/prompt-generator'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.wand2, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Prompt Generator',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create AI prompts for your specific needs',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: SectionHeader(
                      title: 'Categories',
                      onSeeAll: () {
                        // Switch to Categories tab (index 1) in MainLayoutScreen
                        // We will use a Riverpod provider to manage the tab index
                        ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: _chipCategories.length,
                      itemBuilder: (context, index) {
                        final cat = _chipCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: CategoryChip(
                            label: cat,
                            isSelected: false,
                            onTap: () {
                              context.push('/category/${Uri.encodeComponent(cat)}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // Trending Prompts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SectionHeader(
                  title: '🔥 Trending Prompts',
                  onSeeAll: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: BannerAdWidget(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            _buildPromptsList(),

            const SliverToBoxAdapter(child: SizedBox(height: 120)), // Bottom padding for FAB + nav
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Prompt Hub',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Supercharge your AI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textMuted 
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/notifications'),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.border
                    : AppColors.borderLightTheme,
              ),
            ),
            child: const Icon(LucideIcons.bell, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptsList() {
    final trendingAsync = ref.watch(trendingPromptsProvider);
    final selectedAITool = ref.watch(selectedAIToolFilterProvider);

    return trendingAsync.when(
      data: (prompts) {
        final displayPrompts = selectedAITool == 'All'
            ? prompts
            : prompts
                .where((p) =>
                    p.aiTool.toLowerCase().contains(selectedAITool.toLowerCase()) ||
                    p.category.toLowerCase().contains(selectedAITool.toLowerCase()))
                .toList();

        if (displayPrompts.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No prompts found for $selectedAITool',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final prompt = displayPrompts[index];
                final isAdIndex = (index > 0) && ((index + 1) % 8 == 0); // After 7 items, the 8th item slot gets an ad alongside the prompt.
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: PromptCard(
                        prompt: prompt,
                        onTap: () => context.push('/prompt/${prompt.id}'),
                      ),
                    ),
                    if (isAdIndex)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: BannerAdWidget(),
                      ),
                  ],
                );
              },
              childCount: displayPrompts.length,
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: SkeletonLoading(width: double.infinity, height: 130, borderRadius: AppSpacing.radiusMd),
            ),
            childCount: 4,
          ),
        ),
      ),
      error: (e, st) => SliverToBoxAdapter(
        child: Center(
          child: Text('Error loading prompts', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}

