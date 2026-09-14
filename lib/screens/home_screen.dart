import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/skeleton_loading.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger categories sync in background
      ref.read(categoriesProvider);
      // Request in-app review after enough app opens
      ReviewService.instance.checkAndRequestReview(openThreshold: 5);
    });
  }

  Future<void> _requestNotificationPermission() async {
    await NotificationService.instance.requestPermissions();
    
    // Schedule daily prompt notifications
    try {
      final repo = ref.read(promptRepositoryProvider);
      final allPrompts = await repo.getRecentPrompts();
      if (allPrompts.isNotEmpty) {
        await NotificationService.instance.scheduleDailyPrompts(allPrompts);
      }
    } catch (e) {
      debugPrint('Error scheduling daily prompts: $e');
    }

    // Schedule trending photo notifications
    try {
      final repo = ref.read(promptRepositoryProvider);
      final trendingPhotos = await repo.getTrendingPhotos();
      if (trendingPhotos.isNotEmpty) {
        await NotificationService.instance.scheduleDailyTrendingPhotos(trendingPhotos);
      }
    } catch (e) {
      debugPrint('Error scheduling trending photo notifications: $e');
    }
  }

  List<String> get _chipCategories {
    final prefs = ref.read(userPreferencesProvider);
    if (prefs != null && prefs.selectedCategories.isNotEmpty) {
      // Use user's selected categories as primary chips
      final userChips = prefs.selectedCategories.take(4).toList();
      // Add a few popular categories to fill out the row
      const fallbackChips = ['ChatGPT', 'Midjourney', 'SEO Articles', 'React'];
      final result = [...userChips];
      for (final chip in fallbackChips) {
        if (result.length >= 6) break;
        if (!result.contains(chip)) result.add(chip);
      }
      return result;
    }
    return const [
      'ChatGPT',
      'Midjourney',
      'SEO Articles',
      'React',
      'YouTube Scripts',
      'Business Plans'
    ];
  }

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
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(featuredPromptsProvider);
            ref.invalidate(personalizedPromptsProvider);
            ref.invalidate(promptUpdateStreamProvider);
            await ref.read(trendingPhotosProvider.notifier).refresh();
          },
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
                  ],
                ),
              ),
            ),

            // Featured Banners
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 195,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        FeatureBannerCard(
                          title: 'Master ChatGPT',
                          subtitle: 'Top 100+ high-converting prompts',
                          tag: 'OPENAI • CHATGPT',
                          icon: LucideIcons.bot,
                          gradientColors: const [
                            Color(0xFF10A37F), // Official ChatGPT Green
                            Color(0xFF0D8C6C),
                            Color(0xFF075E54),
                          ],
                          onTryNow: () => context.push('/category/ChatGPT'),
                        ),
                        FeatureBannerCard(
                          title: 'Midjourney Art',
                          subtitle: 'Photorealistic & 8K image prompts',
                          tag: 'MIDJOURNEY • V6',
                          icon: LucideIcons.image,
                          gradientColors: const [
                            Color(0xFF2E1065), // Midjourney Deep Cosmic Violet
                            Color(0xFF4C1D95),
                            Color(0xFF6D28D9),
                          ],
                          onTryNow: () => context.push('/category/Midjourney'),
                        ),
                        FeatureBannerCard(
                          title: 'Code Like a Pro',
                          subtitle: 'Supercharge your dev workflow',
                          tag: 'REACT • DEV TOOLS',
                          icon: LucideIcons.code2,
                          gradientColors: const [
                            Color(0xFF087EA4), // Official React Cyan Blue
                            Color(0xFF0284C7),
                            Color(0xFF00B4D8),
                          ],
                          onTryNow: () => context.push('/category/React'),
                        ),
                        FeatureBannerCard(
                          title: 'Viral Marketing',
                          subtitle: 'SEO, Ads & social media copy',
                          tag: 'SEO • GROWTH',
                          icon: LucideIcons.trendingUp,
                          gradientColors: const [
                            Color(0xFFEA580C), // Marketing Flame Orange
                            Color(0xFFD97706),
                            Color(0xFFB45309),
                          ],
                          onTryNow: () => context.push('/category/SEO Articles'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                      dotHeight: 5,
                      dotWidth: 6,
                      expansionFactor: 3.5,
                      spacing: 5,
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
                              context.push('/category/$cat');
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

            // Trending Photos
            _buildTrendingPhotosList(),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SectionHeader(
                  title: _buildPersonalizedSectionTitle(),
                  onSeeAll: () {
                    context.push('/personalized-prompts');
                  },
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
      ),
    );
  }

  Widget _buildAppBar() {
    final prefs = ref.watch(userPreferencesProvider);
    final subtitle = prefs?.selectedGoal != null
        ? '${prefs!.selectedGoal} expert'
        : 'Supercharge your AI';

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
                  subtitle,
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
        GestureDetector(
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

  String _buildPersonalizedSectionTitle() {
    final prefs = ref.watch(userPreferencesProvider);
    if (prefs?.selectedGoal != null) {
      return '✨ For ${prefs!.selectedGoal}';
    }
    return '✨ Just For You';
  }

  Widget _buildPromptsList() {
    final personalizedAsync = ref.watch(personalizedPromptsProvider);

    return personalizedAsync.when(
      data: (prompts) {
        final displayPrompts = prompts.length > 8 ? prompts.sublist(0, 8) : prompts;

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
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: const SkeletonLoading(width: double.infinity, height: 130, borderRadius: AppSpacing.radiusMd),
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

  Widget _buildTrendingPhotosList() {
    final photos = ref.watch(trendingPhotosProvider);
    if (photos.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SectionHeader(
              title: '🖼️ Trending Photos',
              onSeeAll: () {
                context.push('/trending-photos');
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: photos.length > 8 ? 8 : photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => context.push('/prompt/${photo.id}'),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      color: AppColors.surface,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (photo.imageUrl != null && photo.imageUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: photo.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(LucideIcons.image, color: AppColors.textMuted, size: 28),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(LucideIcons.imageOff, color: AppColors.textMuted, size: 28),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              photo.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


