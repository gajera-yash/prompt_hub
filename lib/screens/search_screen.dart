import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _trendingSearches = ['React', 'Midjourney', 'SEO', 'Linux', 'Marketing', 'Flutter', 'Image Generation'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = _searchQuery.isEmpty ? null : ref.watch(searchPromptsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            autofocus: true,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search prompts...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildTrendingSearches()
          : _buildSearchResults(searchResultsAsync),
    );
  }

  Widget _buildTrendingSearches() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRENDING SEARCHES',
            style: AppTextStyles.label.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _trendingSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  setState(() => _searchQuery = search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.trendingUp, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<dynamic>? asyncValue) {
    if (asyncValue == null) return const SizedBox();

    return asyncValue.when(
      data: (prompts) {
        if (prompts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.searchX, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('No prompts found', style: AppTextStyles.h4),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: prompts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PromptCard(
                prompt: prompts[index],
                onTap: () => context.push('/prompt/${prompts[index].id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
    );
  }
}

