import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../data/mock_categories.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  Color _getCategoryColor() {
    // Find the parent group to assign a matching color
    String parentGroup = 'Programming & Development'; // fallback
    AppCategories.categoryGroups.forEach((group, items) {
      if (items.contains(categoryName)) {
        parentGroup = group;
      }
    });
    
    switch (parentGroup) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final promptsAsync = ref.watch(categoryPromptsProvider(categoryName));
    final categoryColor = _getCategoryColor();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            backgroundColor: categoryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                  promptsAsync.maybeWhen(
                    data: (list) => Text(
                      '${list.length} Available Prompts',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circle 1
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Decorative circle 2
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Large faint icon
                    Positioned(
                      bottom: 40,
                      right: 20,
                      child: Icon(
                        LucideIcons.sparkles,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          promptsAsync.when(
            data: (prompts) {
              if (prompts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.folderOpen, size: 48, color: categoryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No prompts available',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for updates',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final prompt = prompts[index];
                      final isAdIndex = (index > 0) && (index % 5 == 0); // Ad every 5 items
                      
                      return Column(
                        children: [
                          if (isAdIndex)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: BannerAdWidget(),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PromptCard(
                              prompt: prompt,
                              onTap: () => context.push('/prompt/${prompt.id}'),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: prompts.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error loading prompts')),
            ),
          ),
        ],
      ),
    );
  }
}
