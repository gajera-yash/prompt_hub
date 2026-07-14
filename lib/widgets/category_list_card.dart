import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/category_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class CategoryListCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryListCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'message-square': return LucideIcons.messageSquare;
      case 'sparkles': return LucideIcons.sparkles;
      case 'bot': return LucideIcons.bot;
      case 'search': return LucideIcons.search;
      case 'image': return LucideIcons.image;
      case 'zap': return LucideIcons.zap;
      case 'palette': return LucideIcons.palette;
      case 'code': return LucideIcons.code;
      case 'smartphone': return LucideIcons.smartphone;
      case 'briefcase': return LucideIcons.briefcase;
      case 'target': return LucideIcons.target;
      case 'trending-up': return LucideIcons.trendingUp;
      case 'file-text': return LucideIcons.fileText;
      case 'users': return LucideIcons.users;
      default: return LucideIcons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.borderLightTheme,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(category.iconName),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: isDark ? AppColors.textMuted : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
