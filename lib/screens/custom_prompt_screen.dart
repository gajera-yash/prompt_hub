import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../models/prompt_model.dart';
import '../providers/data_providers.dart';
import '../widgets/gradient_button.dart';
import '../widgets/voice_input_dialog.dart';

class CustomPromptScreen extends ConsumerStatefulWidget {
  final PromptModel? initialPrompt;
  const CustomPromptScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<CustomPromptScreen> createState() => _CustomPromptScreenState();
}

class _CustomPromptScreenState extends ConsumerState<CustomPromptScreen> {
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  String _selectedFolder = 'Personal';

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _titleController.text = widget.initialPrompt!.title;
      _promptController.text = widget.initialPrompt!.content;
      _selectedFolder = widget.initialPrompt!.category.isNotEmpty
          ? widget.initialPrompt!.category
          : 'Personal';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

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
                setState(() => _selectedFolder = text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _saveAndCopyPrompt() {
    final text = _promptController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter prompt text before saving')),
      );
      return;
    }

    final isEdit = widget.initialPrompt != null;
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (text.length > 35 ? '${text.substring(0, 35)}...' : text);

    final promptModel = PromptModel(
      id: isEdit ? widget.initialPrompt!.id : 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: isEdit
          ? 'Updated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
          : 'Saved under $_selectedFolder folder',
      content: text,
      aiTool: isEdit ? widget.initialPrompt!.aiTool : 'Custom AI',
      category: _selectedFolder,
    );

    ref.read(customPromptsProvider.notifier).saveCustomPrompt(promptModel);
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? 'Prompt updated and copied to clipboard!'
              : 'Prompt saved in "$_selectedFolder" collection and copied!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (isEdit && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = ref.watch(customFoldersProvider);
    final availableFolders = folders.where((f) => f != 'All').toList();
    final isEdit = widget.initialPrompt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Prompt' : 'Custom Prompt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title (Optional)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Give your prompt a title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 20),

            // Select Collection / Folder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Folder / Collection', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAddFolderDialog(folders),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('New Folder'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableFolders.map((folder) {
                  final isSelected = _selectedFolder == folder;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(folder),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFolder = folder);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prompt Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    VoiceInputDialog.show(
                      context,
                      onSpeechResult: (text) {
                        setState(() {
                          if (_promptController.text.isEmpty) {
                            _promptController.text = text;
                          } else {
                            _promptController.text += ' $text';
                          }
                        });
                      },
                    );
                  },
                  icon: const Icon(LucideIcons.mic, size: 16, color: AppColors.primary),
                  label: const Text('Voice Input'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: TextField(
                controller: _promptController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Type or paste your prompt here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: isEdit ? 'Update & Copy Prompt' : 'Save & Copy Prompt',
                icon: isEdit ? LucideIcons.check : LucideIcons.bookmark,
                onPressed: _saveAndCopyPrompt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
