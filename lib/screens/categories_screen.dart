import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/data_providers.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/banner_ad_widget.dart';
import '../core/utils/ad_helper.dart';
import '../data/mock_categories.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'All';

  final List<String> _tabs = [
    'All',
    'Image Generation',
    'Programming & Development',
    'AI & Prompt Engineering',
    'Content Creation',
    'Digital Marketing',
    'Business & Startup',
    'Design',
    'Lifestyle',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getColorForGroup(String group) {
    switch (group) {
      case 'Programming & Development': return const Color(0xFF3B82F6); // Blue
      case 'AI & Prompt Engineering': return const Color(0xFF8B5CF6); // Purple
      case 'Image Generation': return const Color(0xFFEAB308); // Yellow
      case 'Content Creation': return const Color(0xFFEC4899); // Pink
      case 'Digital Marketing': return const Color(0xFFF59E0B); // Amber
      case 'Business & Startup': return const Color(0xFF10B981); // Emerald
      case 'Design': return const Color(0xFFF43F5E); // Rose
      case 'Lifestyle': return const Color(0xFF14B8A6); // Teal
      case 'Freelancing': return const Color(0xFF6366F1); // Indigo
      case 'Career': return const Color(0xFF06B6D4); // Cyan
      case 'Education': return const Color(0xFF84CC16); // Lime
      case 'E-commerce': return const Color(0xFFF97316); // Orange
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Premium Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.layoutTemplate, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Discover Categories', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.border : AppColors.borderLightTheme),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search over 150+ categories...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Dynamic Tabs
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == tab;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedTab = tab);
                      },
                      selectedColor: isDark ? Colors.white : AppColors.primary,
                      backgroundColor: theme.colorScheme.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : (isDark ? AppColors.border : AppColors.borderLightTheme),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Categories List
            Expanded(
              child: categoriesAsync.when(
                data: (allCategories) {
                  var filteredCategories = allCategories.where((category) {
                    return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  final Map<String, List<dynamic>> groupedCategories = {};
                  for (var group in AppCategories.categoryGroups.keys) {
                    final groupItems = AppCategories.categoryGroups[group]!;
                    final matchedItems = filteredCategories.where((c) => groupItems.contains(c.name)).toList();
                    if (matchedItems.isNotEmpty) {
                      groupedCategories[group] = matchedItems;
                    }
                  }

                  var displayGroups = groupedCategories.keys.toList();
                  if (_selectedTab != 'All') {
                    displayGroups = displayGroups.where((group) => group == _selectedTab).toList();
                  }

                  if (displayGroups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.search, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text('No categories found', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Try searching for something else.', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 120),
                    itemCount: displayGroups.length,
                    itemBuilder: (context, index) {
                      final groupName = displayGroups[index];
                      final items = groupedCategories[groupName]!;
                      
                      final isAdIndex = (index > 0) && (index % 3 == 0);
                      final groupColor = _getColorForGroup(groupName);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAdIndex)
                            const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.lg),
                              child: BannerAdWidget(),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: groupColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  groupName.toUpperCase(),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final cat = items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _PremiumCategoryCard(
                                  categoryName: cat.name,
                                  iconName: cat.iconName,
                                  count: cat.promptCount,
                                  color: groupColor,
                                  onTap: () {
                                    AdHelper.showInterstitialAd(
                                      onAdDismissed: () => context.push('/category/${Uri.encodeComponent(cat.name)}'),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: 5,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: SkeletonLoading(
                      width: double.infinity,
                      height: 100,
                      borderRadius: AppSpacing.radiusLg,
                    ),
                  ),
                ),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCategoryCard extends StatelessWidget {
  final String categoryName;
  final String iconName;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _PremiumCategoryCard({
    required this.categoryName,
    required this.iconName,
    required this.count,
    required this.color,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'message-square': return LucideIcons.messageSquare;
      case 'sparkles': return LucideIcons.sparkles;
      case 'bot': return LucideIcons.bot;
      case 'search': return LucideIcons.search;
      case 'image': return LucideIcons.image;
      case 'zap': return LucideIcons.zap;
      case 'palette': return LucideIcons.palette;
      case 'code': return LucideIcons.code;
      case 'smartphone': return LucideIcons.smartphone;
      case 'briefcase': return LucideIcons.briefcase;
      case 'target': return LucideIcons.target;
      case 'trending-up': return LucideIcons.trendingUp;
      case 'file-text': return LucideIcons.fileText;
      case 'users': return LucideIcons.users;
      default: return LucideIcons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: isDark ? 0.2 : 0.8),
              color.withValues(alpha: isDark ? 0.05 : 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
          border: isDark ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                _getIconData(iconName),
                size: 100,
                color: isDark ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isDark ? color : Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.layers, size: 12, color: isDark ? Colors.white70 : Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$count Prompts',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.white70 : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: isDark ? Colors.white54 : Colors.white70,
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
