import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class PromptCard extends StatelessWidget {
  final dynamic prompt;
  final VoidCallback onTap;

  const PromptCard({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  Color _getAiToolColor(String aiTool) {
    switch (aiTool) {
      case 'ChatGPT': return const Color(0xFF10A37F);
      case 'Gemini': return const Color(0xFF4285F4);
      case 'Claude': return const Color(0xFFCC9B7A);
      case 'Midjourney': return const Color(0xFF7C4DFF);
      case 'DeepSeek': return const Color(0xFF2196F3);
      default: return AppColors.primary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner': return AppColors.accentGreen;
      case 'Intermediate': return AppColors.warning;
      case 'Advanced': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLightTheme,
          ),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: AI Tool & Difficulty
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: _getAiToolColor(prompt.aiTool).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    prompt.aiTool,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getAiToolColor(prompt.aiTool),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(prompt.difficulty).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    prompt.difficulty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getDifficultyColor(prompt.difficulty),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Title
            Text(
              prompt.title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Description
            Text(
              prompt.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            // Footer
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '${(prompt.rating as num?)?.toDouble() ?? 4.8}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Text(
                  ' (${(prompt.ratingCount as int?) ?? 142})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: isDark ? AppColors.textMuted : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.copy_outlined, size: 14,
                    color: isDark ? AppColors.textMuted : const Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  '${_formatCount(prompt.copyCount)} copies',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isDark ? AppColors.textMuted : const Color(0xFF9CA3AF),
                  ),
                ),
                const Spacer(),
                Text(
                  prompt.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isDark ? AppColors.textMuted : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
