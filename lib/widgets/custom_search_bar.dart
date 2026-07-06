import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: onTap == null,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search 500+ prompts...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            prefixIcon: Icon(LucideIcons.search, color: AppColors.textMuted, size: 20),
            suffixIcon: onFilterTap != null
                ? IconButton(
                    icon: Icon(LucideIcons.slidersHorizontal, color: AppColors.textMuted, size: 18),
                    onPressed: onFilterTap,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

