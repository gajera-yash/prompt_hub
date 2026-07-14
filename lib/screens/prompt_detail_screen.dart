import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/prompt_model.dart';
import '../providers/data_providers.dart';
import '../core/utils/ad_helper.dart';
import '../widgets/folder_select_sheet.dart';
import '../widgets/gradient_button.dart';
import '../widgets/prompt_card.dart';
import '../widgets/prompt_share_sheet.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  final String promptId;
  const PromptDetailScreen({super.key, required this.promptId});

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  final Map<String, TextEditingController> _variableControllers = {};
  String _currentPromptContent = '';

  List<String> _extractVariables(String text) {
    final RegExp regExp = RegExp(r'\[(.*?)\]');
    final matches = regExp.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  void _updatePromptWithVariables(String originalContent) {
    String updated = originalContent;
    _variableControllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        updated = updated.replaceAll('[$key]', controller.text);
      }
    });
    setState(() {
      _currentPromptContent = updated;
    });
  }

  @override
  void dispose() {
    for (var controller in _variableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _launchAIPlatform(String platform) async {
    Clipboard.setData(ClipboardData(text: _currentPromptContent));
    String urlStr = '';
    if (platform == 'ChatGPT') {
      urlStr = 'https://chatgpt.com/?q=${Uri.encodeComponent(_currentPromptContent)}';
    } else if (platform == 'Gemini') {
      urlStr = 'https://gemini.google.com/?q=${Uri.encodeComponent(_currentPromptContent)}';
    } else if (platform == 'Claude') {
      urlStr = 'https://claude.ai/new';
    }

    final Uri url = Uri.parse(urlStr);
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && platform == 'Gemini') {
        await launchUrl(Uri.parse('https://gemini.google.com/'), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final promptAsync = ref.watch(promptByIdProvider(widget.promptId));
    final savedIds = ref.watch(savedPromptsProvider);
    final isSaved = savedIds.contains(widget.promptId);

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
        actions: [
          // Bookmark button
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                key: ValueKey(isSaved),
                color: isSaved ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              if (isSaved) {
                ref.read(savedPromptsProvider.notifier).toggleSave(widget.promptId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Removed from saved'),
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                FolderSelectSheet.show(context, promptId: widget.promptId);
              }
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {
              promptAsync.whenData((p) {
                if (p != null) {
                  PromptShareSheet.show(context, p);
                }
              });
            },
          ),
        ],
      ),
      body: promptAsync.when(
        data: (prompt) {
          if (prompt == null) {
            return Center(child: Text('Prompt not found.', style: AppTextStyles.bodyLarge));
          }

          if (_variableControllers.isEmpty) {
            _currentPromptContent = prompt.content;
            final vars = _extractVariables(prompt.content);
            for (var v in vars) {
              _variableControllers[v] = TextEditingController();
              _variableControllers[v]!.addListener(() {
                _updatePromptWithVariables(prompt.content);
              });
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        prompt.title,
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Tags Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      _buildTag('⭐ ${prompt.rating} (${prompt.ratingCount} reviews)', Colors.amber),
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag(prompt.category, AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag(prompt.aiTool, AppColors.accent),
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag(prompt.difficulty, AppColors.accentGreen),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Variables Section
                if (_variableControllers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text('🔧 Fill Variables', style: AppTextStyles.h4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: _variableControllers.keys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TextField(
                            controller: _variableControllers[key],
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              labelText: key.toUpperCase(),
                              labelStyle: AppTextStyles.label,
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Prompt Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('📋 Prompt', style: AppTextStyles.h4),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SelectableText(
                    _currentPromptContent,
                    style: AppTextStyles.monospace,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Copy Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: GradientButton(
                    text: 'Copy Prompt',
                    icon: LucideIcons.copy,
                    onPressed: () {
                      AdHelper.showInterstitialAd(
                        onAdDismissed: () {
                          Clipboard.setData(ClipboardData(text: _currentPromptContent));
                          HapticFeedback.selectionClick();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Prompt copied to clipboard!'),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Direct Open in AI App Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚀 Open Directly in AI App', style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAIAppButton(
                              title: 'ChatGPT',
                              icon: LucideIcons.sparkles,
                              gradientColors: [const Color(0xFF10A37F), const Color(0xFF0D8A6C)],
                              onTap: () => _launchAIPlatform('ChatGPT'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAIAppButton(
                              title: 'Gemini',
                              icon: LucideIcons.bot,
                              gradientColors: [const Color(0xFF4285F4), const Color(0xFF9B72CB)],
                              onTap: () => _launchAIPlatform('Gemini'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAIAppButton(
                              title: 'Claude',
                              icon: LucideIcons.cpu,
                              gradientColors: [const Color(0xFFD97757), const Color(0xFFB85435)],
                              onTap: () => _launchAIPlatform('Claude'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Modern Rating & Personal Notes Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildRatingAndNotesCard(widget.promptId, context, prompt),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Related Prompts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('Related Prompts', style: AppTextStyles.h3),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildRelatedPrompts(prompt.category),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, st) => Center(child: Text('Error loading prompt', style: AppTextStyles.bodyLarge)),
      ),
    );
  }

  Widget _buildRatingAndNotesCard(String promptId, BuildContext context, PromptModel prompt) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.watch(promptRatingsProvider);
    final currentRating = ref.read(promptRatingsProvider.notifier).getRating(promptId);

    String ratingText = 'Tap to rate';
    if (currentRating == 5) {
      ratingText = '5.0 Excellent! ⭐';
    } else if (currentRating == 4) {
      ratingText = '4.0 Great! 👍';
    } else if (currentRating == 3) {
      ratingText = '3.0 Good 🙂';
    } else if (currentRating == 2) {
      ratingText = '2.0 Average';
    } else if (currentRating == 1) {
      ratingText = '1.0 Needs Work';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLightTheme,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community Rating Summary Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${prompt.rating} Community Rating',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '(${prompt.ratingCount} user reviews)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textMuted : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Header: Your Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Your Rating', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentRating > 0
                      ? Colors.amber.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ratingText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: currentRating > 0 ? Colors.amber[800] : (isDark ? Colors.white54 : Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Star Rating Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.amber.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= currentRating;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(promptRatingsProvider.notifier).setRating(promptId, starIndex.toDouble());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isSelected ? Colors.amber : (isDark ? Colors.white30 : Colors.grey[400]),
                      size: isSelected ? 32 : 28,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Header: Personal Notes
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.fileEdit, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Personal Notes & Tips', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          _buildNotesSection(promptId),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String promptId) {
    ref.watch(promptNotesProvider);
    final savedNote = ref.read(promptNotesProvider.notifier).getNote(promptId);
    final controller = TextEditingController(text: savedNote);

    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Add your custom usage notes, tips, or parameters here...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(promptNotesProvider.notifier).saveNote(promptId, controller.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personal note saved!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(LucideIcons.save, size: 16),
            label: const Text('Save Note'),
          ),
        ),
      ],
    );
  }

  Widget _buildAIAppButton({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRelatedPrompts(String category) {
    final relatedAsync = ref.watch(categoryPromptsProvider(category));

    return relatedAsync.when(
      data: (prompts) {
        final related = prompts.where((p) => p.id != widget.promptId).take(5).toList();
        if (related.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('No related prompts found.'),
          );
        }
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: related.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                child: PromptCard(
                  prompt: related[index],
                  onTap: () {
                    context.push('/prompt/${related[index].id}');
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

