import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/data_providers.dart';
import '../core/utils/ad_helper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/prompt_card.dart';
import '../services/review_service.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  final String promptId;
  const PromptDetailScreen({super.key, required this.promptId});

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  final Map<String, TextEditingController> _variableControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReviewService.instance.recordActionAndCheckReview(context, triggerThreshold: 3);
    });
  }
  String _currentPromptContent = '';

  void _handleUnlockWithRewardedAd(String promptId) {
    AdHelper.loadRewardedAd();
    AdHelper.showRewardedAd(
      onUserEarnedReward: (reward) async {
        await ref.read(unlockedPromptsProvider.notifier).unlockPrompt(promptId);
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.accentGreen),
                  SizedBox(width: 10),
                  Text('PRO Prompt Unlocked! 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
    );
  }

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
              ref.read(savedPromptsProvider.notifier).toggleSave(widget.promptId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isSaved ? 'Removed from saved' : 'Added to saved'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {
              promptAsync.whenData((p) {
                if (p != null) {
                  AdHelper.showInterstitialAd(
                    onAdDismissed: () {
                      SharePlus.instance.share(
                        ShareParams(text: p.content, title: p.title),
                      );
                    },
                  );
                }
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: promptAsync.when(
        data: (prompt) {
          if (prompt == null) return const SizedBox.shrink();
          final isUnlocked = !prompt.isPremium || ref.watch(unlockedPromptsProvider).contains(prompt.id);

          return Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: isUnlocked
                ? GradientButton(
                    text: 'Copy Prompt',
                    icon: LucideIcons.copy,
                    onPressed: () {
                      AdHelper.showSmartInterstitialAd(
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
                            ReviewService.instance.recordActionAndCheckReview(context, triggerThreshold: 3);
                          }
                        },
                      );
                    },
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleUnlockWithRewardedAd(prompt.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Watch Video to Unlock Prompt 👑',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      body: promptAsync.when(
        data: (prompt) {
          if (prompt == null) {
            return Center(child: Text('Prompt not found.', style: AppTextStyles.bodyLarge));
          }

          final isUnlocked = !prompt.isPremium || ref.watch(unlockedPromptsProvider).contains(prompt.id);

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
                // Optional Image Section
                if (prompt.imageUrl != null && prompt.imageUrl!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 250,
                    margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(prompt.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

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
                      if (prompt.isPremium) ...[
                        _buildTag(
                          isUnlocked ? '👑 PRO UNLOCKED' : '👑 PRO',
                          const Color(0xFFFFB800),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      _buildTag(prompt.category, AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag(prompt.aiTool, AppColors.accent),
                      const SizedBox(width: AppSpacing.sm),
                      _buildTag(prompt.difficulty, AppColors.accentGreen),
                    ],
                  ),
                ),

                if (prompt.isPremium && !isUnlocked) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFB800).withValues(alpha: 0.15),
                          const Color(0xFFFF8A00).withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFFFB800),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Exclusive PRO Prompt',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFB800),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Watch a short video ad to unlock full prompt & customization.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // Variables Section (Available when unlocked)
                if (isUnlocked && _variableControllers.isNotEmpty) ...[
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
                  child: Row(
                    children: [
                      Text('📋 Prompt', style: AppTextStyles.h4),
                      const Spacer(),
                      if (prompt.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                            ),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isUnlocked ? 'UNLOCKED' : 'LOCKED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isUnlocked)
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
                  )
                else
                  // Locked Prompt Preview Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _currentPromptContent.length > 90
                              ? '${_currentPromptContent.substring(0, 90)}...\n\n[PRO Content Hidden - Watch short ad to reveal]'
                              : _currentPromptContent,
                          style: AppTextStyles.monospace.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFFFB800),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'PRO Prompt Locked 👑',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Watch a quick video ad to unlock the complete prompt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => _handleUnlockWithRewardedAd(prompt.id),
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                          label: const Text('Watch Video to Unlock'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFB800),
                            side: const BorderSide(color: Color(0xFFFFB800)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl),

                // Actions: AI Direct Launch Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.bot, size: 20, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Run Prompt Directly', style: AppTextStyles.h4),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _buildAIIconButton(
                              context,
                              'ChatGPT',
                              'https://chatgpt.com',
                              LucideIcons.messageSquare,
                              const Color(0xFF10A37F),
                              isUnlocked: isUnlocked,
                              onLockedTap: () => _handleUnlockWithRewardedAd(prompt.id),
                            ),
                            _buildAIIconButton(
                              context,
                              'Claude',
                              'https://claude.ai',
                              LucideIcons.cpu,
                              const Color(0xFFD97757),
                              isUnlocked: isUnlocked,
                              onLockedTap: () => _handleUnlockWithRewardedAd(prompt.id),
                            ),
                            _buildAIIconButton(
                              context,
                              'Gemini',
                              'https://gemini.google.com',
                              LucideIcons.sparkles,
                              const Color(0xFF1A73E8),
                              isUnlocked: isUnlocked,
                              onLockedTap: () => _handleUnlockWithRewardedAd(prompt.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildAIIconButton(
    BuildContext context,
    String label,
    String baseUrl,
    IconData icon,
    Color color, {
    bool isUnlocked = true,
    VoidCallback? onLockedTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          if (!isUnlocked) {
            onLockedTap?.call();
            return;
          }
          if (_currentPromptContent.isEmpty) return;
          
          // Copy to clipboard for convenience
          await Clipboard.setData(ClipboardData(text: _currentPromptContent));

          final String encodedPrompt = Uri.encodeComponent(_currentPromptContent);
          String fullUrl = baseUrl;
          
          if (label == 'ChatGPT') {
            fullUrl = '$baseUrl/?q=$encodedPrompt';
          } else if (label == 'Claude') {
            fullUrl = '$baseUrl/new?q=$encodedPrompt';
          } else if (label == 'Gemini') {
            fullUrl = '$baseUrl/app?q=$encodedPrompt';
          }
          
          final uri = Uri.parse(fullUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $label')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

