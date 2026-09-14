import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/data_providers.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/prompt_card.dart';
import '../widgets/skeleton_loading.dart';
import '../core/theme/app_text_styles.dart';

class PersonalizedPromptsScreen extends ConsumerWidget {
  const PersonalizedPromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizedAsync = ref.watch(personalizedPromptsProvider);
    final prefs = ref.watch(userPreferencesProvider);
    
    final title = prefs?.selectedGoal != null
        ? 'For ${prefs!.selectedGoal}'
        : 'Just For You';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: personalizedAsync.when(
        data: (prompts) {
          if (prompts.isEmpty) {
            return const Center(child: Text('No prompts found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(personalizedPromptsProvider);
              await ref.read(personalizedPromptsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: PromptCard(
                    prompt: prompt,
                    onTap: () => context.push('/prompt/${prompt.id}'),
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 8,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SkeletonLoading(width: double.infinity, height: 130, borderRadius: AppSpacing.radiusMd),
          ),
        ),
        error: (e, st) => Center(
          child: Text('Error loading prompts', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
