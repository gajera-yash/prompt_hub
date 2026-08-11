import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../models/prompt_model.dart';

class PromptShareSheet extends StatefulWidget {
  final PromptModel prompt;
  const PromptShareSheet({super.key, required this.prompt});

  static void show(BuildContext context, PromptModel prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromptShareSheet(prompt: prompt),
    );
  }

  @override
  State<PromptShareSheet> createState() => _PromptShareSheetState();
}

class _PromptShareSheetState extends State<PromptShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedThemeIndex = 0;
  bool _isExporting = false;

  final List<List<Color>> _themes = [
    [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)], // Cyber Purple
    [const Color(0xFFF43F5E), const Color(0xFFFB923C)], // Sunset Glow
    [const Color(0xFF10B981), const Color(0xFF06B6D4)], // Emerald Ocean
    [const Color(0xFF0F172A), const Color(0xFF1E293B)], // Midnight Slate
  ];

  final List<String> _themeNames = ['Cyber', 'Sunset', 'Emerald', 'Midnight'];

  Future<void> _shareCardAsImage() async {
    setState(() => _isExporting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'AI_Prompt_${widget.prompt.title.replaceAll(' ', '_')}.png',
        );

        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: '✨ Check out this prompt created with AI Prompt Hub!\n\n${widget.prompt.title}',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
      _shareAsFormattedText();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _shareAsFormattedText() {
    final text = '''✨ ${widget.prompt.title} ✨
Category: #${widget.prompt.category.replaceAll(' ', '')}
AI Tool: #${widget.prompt.aiTool.replaceAll(' ', '')}

📋 PROMPT:
${widget.prompt.content}

Shared via AI Prompt Hub 🚀''';

    SharePlus.instance.share(
      ShareParams(text: text, title: widget.prompt.title),
    );
  }

  void _copyFormattedText() {
    final text = '''✨ ${widget.prompt.title} ✨
Category: #${widget.prompt.category.replaceAll(' ', '')}
AI Tool: #${widget.prompt.aiTool.replaceAll(' ', '')}

📋 PROMPT:
${widget.prompt.content}

Shared via AI Prompt Hub 🚀''';

    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formatted prompt copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentGradient = _themes[_selectedThemeIndex];
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
            const SizedBox(height: 12),

            // Header Title
            Row(
              children: [
                const Icon(LucideIcons.share2, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Share Prompt Card',
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

            // Scrollable Content area to prevent overflow
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Selector Chips
                    Text(
                      'Select Card Theme',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMuted : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_themes.length, (index) {
                          final isSelected = _selectedThemeIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: _themes[index]),
                                ),
                              ),
                              label: Text(_themeNames[index]),
                              selected: isSelected,
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedThemeIndex = index);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Preview Repaint Boundary
                    RepaintBoundary(
                      key: _cardKey,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: currentGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: currentGradient.first.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
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
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.prompt.category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: const [
                                    Icon(LucideIcons.sparkles, color: Colors.white70, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'AI PROMPT HUB',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.prompt.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.prompt.content,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Share Actions Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _shareCardAsImage,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.image, size: 18),
                    label: Text(_isExporting ? 'Creating Card Image...' : 'Share Image Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyFormattedText,
                    icon: const Icon(LucideIcons.copy, size: 18),
                    label: const Text('Copy Text'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
