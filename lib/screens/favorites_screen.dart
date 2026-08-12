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
    final standardIds = savedIds.where((id) => !id.startsWith('gen_')).toList();
    final generatedIds = savedIds.where((id) => id.startsWith('gen_')).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D2D) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? AppColors.textMuted : Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    tabs: const [
                      Tab(text: 'Saved Prompts'),
                      Tab(text: 'Generated AI'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildList(context, ref, standardIds, isDark, theme, 'No saved prompts', 'Save your favorite prompts from the home feed.'),
                    _buildList(context, ref, generatedIds, isDark, theme, 'No generated prompts', 'Create custom prompts using the Prompt Generator.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<String> ids, bool isDark, ThemeData theme, String emptyTitle, String emptySubtitle) {
    if (ids.isEmpty) {
      return Center(
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
            Text(emptyTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        final promptId = ids.elementAt(index);
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
          error: (error, stackTrace) => const SizedBox.shrink(),
        );
      },
    );
  }
}
