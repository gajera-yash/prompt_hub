import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedPromptsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.sunsetGradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.heart, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Favorites', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '${savedIds.length} saved prompts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textMuted : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: savedIds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.heartOff, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24),
                          Text('No favorites yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Save your favorite prompts to access\nthem quickly later.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      itemCount: savedIds.length,
                      itemBuilder: (context, index) {
                        final promptId = savedIds.elementAt(index);
                        final promptAsync = ref.watch(promptByIdProvider(promptId));
                        
                        return promptAsync.when(
                          data: (prompt) {
                            if (prompt == null) return const SizedBox.shrink();
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                key: Key(prompt.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(LucideIcons.trash2, color: Colors.white, size: 28),
                                ),
                                onDismissed: (direction) {
                                  ref.read(savedPromptsProvider.notifier).toggleSave(prompt.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Prompt removed from favorites'),
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          ref.read(savedPromptsProvider.notifier).toggleSave(prompt.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: isDark ? null : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: PromptCard(
                                    prompt: prompt,
                                    onTap: () => context.push('/prompt/${prompt.id}'),
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
