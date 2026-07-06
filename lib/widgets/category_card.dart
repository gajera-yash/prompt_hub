import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/category_model.dart';
import '../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
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
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [],
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(category.iconName),
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
