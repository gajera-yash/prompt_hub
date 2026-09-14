import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../services/local_storage_service.dart';
import '../services/review_service.dart';

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ReviewDialog(),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleRateOnPlayStore() async {
    final storage = await LocalStorageService.getInstance();
    await storage.setHasRatedApp(true);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    await ReviewService.instance.openPlayStore();
  }

  Future<void> _handleSubmitFeedback() async {
    setState(() => _isSubmitting = true);
    final storage = await LocalStorageService.getInstance();
    // Reset counter so they aren't bugged immediately
    await storage.resetReviewActionCount();
    
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you! Your feedback helps us improve.'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  Future<void> _handleDismiss() async {
    final storage = await LocalStorageService.getInstance();
    await storage.resetReviewActionCount();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  String _getRatingFeedbackText() {
    switch (_selectedRating) {
      case 5:
        return 'Loved it! Best AI Prompts! 🚀';
      case 4:
        return 'Very good experience! 👍';
      case 3:
        return 'It was okay. 🙂';
      case 2:
        return 'Needs improvement. 😕';
      case 1:
        return 'Disappointing. 😞';
      default:
        return 'Tap a star to rate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighRating = _selectedRating >= 4;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Star Badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Enjoying AI Prompt Hub?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              isHighRating
                  ? 'Your 5-star rating on Google Play Store helps us keep adding fresh & free AI prompts!'
                  : 'Please let us know how we can make AI Prompt Hub better for you.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 5 Stars Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isSelected = starNumber <= _selectedRating;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedRating = starNumber;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        Icons.star_rounded,
                        size: 38,
                        color: isSelected
                            ? const Color(0xFFFFB800)
                            : (isDark
                                ? AppColors.borderLight
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Dynamic Rating text
            Text(
              _getRatingFeedbackText(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isHighRating
                    ? const Color(0xFFFFB800)
                    : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Conditional View: Low Rating Feedback input
            if (!isHighRating) ...[
              TextField(
                controller: _feedbackController,
                maxLines: 2,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'What can we improve? (Optional)',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.background : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHighRating
                        ? AppColors.primaryGradient
                        : [AppColors.surfaceLight, AppColors.border],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: isHighRating
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : (isHighRating
                          ? _handleRateOnPlayStore
                          : _handleSubmitFeedback),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHighRating ? LucideIcons.star : LucideIcons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        isHighRating
                            ? 'Rate on Google Play'
                            : 'Submit Feedback',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Maybe Later button
            TextButton(
              onPressed: _handleDismiss,
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
