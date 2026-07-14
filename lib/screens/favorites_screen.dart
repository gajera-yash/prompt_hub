import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../models/prompt_model.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';
import 'custom_prompt_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Collection / Folder'),
        content: TextField(
          controller: folderController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name (e.g. YouTube, Midjourney)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = folderController.text.trim();
              if (text.isNotEmpty) {
                ref.read(customFoldersProvider.notifier).addFolder(text);
                ref.read(selectedFolderFilterProvider.notifier).setFolder(text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedPromptsProvider);
    final customPrompts = ref.watch(customPromptsProvider);
    final folders = ref.watch(customFoldersProvider);
    final selectedFolder = ref.watch(selectedFolderFilterProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter custom prompts based on selected folder
    final filteredCustomPrompts = selectedFolder == 'All'
        ? customPrompts
        : customPrompts.where((p) => p.category.toLowerCase() == selectedFolder.toLowerCase()).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Screen Title Header
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Collections',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${savedIds.length} saved • ${customPrompts.length} generated',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textMuted : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.folderPlus, size: 22),
                      tooltip: 'New Folder',
                      onPressed: () => _showAddFolderDialog(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Modern TabBar Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? AppColors.textMuted : Colors.grey[700],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.bookmark, size: 16),
                            const SizedBox(width: 8),
                            Text('Saved (${savedIds.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.sparkles, size: 16),
                            const SizedBox(width: 8),
                            Text('Generated (${customPrompts.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Folder Filter Chips Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ...folders.map((folder) {
                      final isSelected = selectedFolder == folder;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(folder),
                          selectedColor: AppColors.secondary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          onSelected: (_) {
                            ref.read(selectedFolderFilterProvider.notifier).setFolder(folder);
                          },
                        ),
                      );
                    }),
                    IconButton(
                      icon: const Icon(LucideIcons.plus, size: 18),
                      tooltip: 'Add Folder',
                      onPressed: () => _showAddFolderDialog(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // TabBar View Content
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Saved Catalog Prompts
                    _buildSavedTab(context, ref, savedIds, selectedFolder, theme, isDark),

                    // Tab 2: Generated & Custom Prompts
                    _buildGeneratedTab(context, ref, filteredCustomPrompts, selectedFolder, theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tab 1: Saved Prompts ───
  Widget _buildSavedTab(
    BuildContext context,
    WidgetRef ref,
    Set<String> savedIds,
    String selectedFolder,
    ThemeData theme,
    bool isDark,
  ) {
    if (savedIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
              Text(
                'No saved prompts yet',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse prompts in the app and tap the heart icon to save them here for quick access.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: savedIds.length,
      itemBuilder: (context, index) {
        final promptId = savedIds.elementAt(index);
        final promptAsync = ref.watch(promptByIdProvider(promptId));

        return promptAsync.when(
          data: (prompt) {
            if (prompt == null) return const SizedBox.shrink();

            // Apply Folder Filter using persisted folder mapping
            ref.watch(savedPromptFoldersProvider);
            final assignedFolder = ref.read(savedPromptFoldersProvider.notifier).getFolder(prompt.id, prompt.category);
            if (selectedFolder != 'All' &&
                !assignedFolder.toLowerCase().contains(selectedFolder.toLowerCase()) &&
                !prompt.category.toLowerCase().contains(selectedFolder.toLowerCase())) {
              return const SizedBox.shrink();
            }

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
                      content: const Text('Prompt removed from saved'),
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
                    boxShadow: isDark
                        ? null
                        : [
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
          error: (e, s) => const SizedBox.shrink(),
        );
      },
    );
  }

  // ─── Tab 2: Generated Prompts ───
  Widget _buildGeneratedTab(
    BuildContext context,
    WidgetRef ref,
    List<PromptModel> customPrompts,
    String selectedFolder,
    ThemeData theme,
    bool isDark,
  ) {
    if (customPrompts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.folderOpen, size: 48, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              Text(
                selectedFolder == 'All'
                    ? 'No generated prompts yet'
                    : 'No prompts in "$selectedFolder"',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create custom prompts or use AI Architect to generate prompts saved in your collections.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/custom-prompt'),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Create New Prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: customPrompts.length,
      itemBuilder: (context, index) {
        final prompt = customPrompts[index];

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
              ref.read(customPromptsProvider.notifier).deleteCustomPrompt(prompt.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Generated prompt deleted'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      ref.read(customPromptsProvider.notifier).saveCustomPrompt(prompt);
                    },
                  ),
                ),
              );
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/prompt/${prompt.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.borderLightTheme,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prompt.category,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 18),
                          tooltip: 'Edit Prompt',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomPromptScreen(initialPrompt: prompt),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.copy, size: 18),
                          tooltip: 'Copy Prompt',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: prompt.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prompt copied to clipboard!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (prompt.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        prompt.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textMuted : Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        prompt.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
