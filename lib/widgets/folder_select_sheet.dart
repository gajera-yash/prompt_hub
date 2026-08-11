import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../providers/data_providers.dart';

class FolderSelectSheet extends ConsumerStatefulWidget {
  final String promptId;
  final Function(String selectedFolder)? onFolderSelected;

  const FolderSelectSheet({
    super.key,
    required this.promptId,
    this.onFolderSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String promptId,
    Function(String selectedFolder)? onFolderSelected,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FolderSelectSheet(
        promptId: promptId,
        onFolderSelected: onFolderSelected,
      ),
    );
  }

  @override
  ConsumerState<FolderSelectSheet> createState() => _FolderSelectSheetState();
}

class _FolderSelectSheetState extends ConsumerState<FolderSelectSheet> {
  void _showAddFolderDialog(List<String> folders) {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Collection'),
        content: TextField(
          controller: folderController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name (e.g. YouTube, Marketing)',
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
                _selectFolder(text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _selectFolder(String folderName) {
    ref.read(savedPromptsProvider.notifier).toggleSave(widget.promptId);
    ref.read(savedPromptFoldersProvider.notifier).setFolder(widget.promptId, folderName);
    if (widget.onFolderSelected != null) {
      widget.onFolderSelected!(folderName);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prompt saved in "$folderName" collection!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(customFoldersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availableFolders = folders.where((f) => f != 'All').toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                const Icon(LucideIcons.folderHeart, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Select Folder / Collection',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Choose which collection to save this prompt into:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textMuted : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // List of Folders
            Column(
              children: [
                ...availableFolders.map((folder) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? AppColors.border : Colors.grey[200]!,
                        ),
                      ),
                      tileColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
                      leading: const Icon(LucideIcons.folder, color: AppColors.secondary),
                      title: Text(folder, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(LucideIcons.chevronRight, size: 18),
                      onTap: () => _selectFolder(folder),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showAddFolderDialog(folders),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create New Collection'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
