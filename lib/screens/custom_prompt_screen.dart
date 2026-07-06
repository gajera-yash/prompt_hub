import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class CustomPromptScreen extends StatefulWidget {
  const CustomPromptScreen({super.key});

  @override
  State<CustomPromptScreen> createState() => _CustomPromptScreenState();
}

class _CustomPromptScreenState extends State<CustomPromptScreen> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write your prompt', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _promptController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Type your prompt here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Copy Prompt',
                icon: LucideIcons.copy,
                onPressed: () {
                  if (_promptController.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _promptController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prompt copied!')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
