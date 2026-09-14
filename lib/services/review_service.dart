import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_storage_service.dart';
import '../widgets/review_dialog.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._();
  ReviewService._();
  static ReviewService get instance => _instance;

  final InAppReview _inAppReview = InAppReview.instance;
  static const String _playStorePackageName = 'com.ai_prompt_hub.setuvio';

  /// Call this when a user performs a key action (e.g. copying prompt or viewing detail).
  /// Automatically displays ReviewDialog after [triggerThreshold] actions.
  Future<void> recordActionAndCheckReview(
    BuildContext context, {
    int triggerThreshold = 3,
  }) async {
    try {
      final storage = await LocalStorageService.getInstance();

      // If user has already rated the app, never prompt again
      if (storage.hasRatedApp()) return;

      await storage.incrementReviewActionCount();
      final currentActions = storage.getReviewActionCount();

      if (currentActions >= triggerThreshold) {
        if (!context.mounted) return;
        // Delay slightly for smooth UX after action
        await Future.delayed(const Duration(milliseconds: 600));
        if (!context.mounted) return;
        await ReviewDialog.show(context);
      }
    } catch (e) {
      debugPrint('ReviewService: Error recording action for review: $e');
    }
  }

  /// Opens the app listing on Google Play Store
  Future<void> openPlayStore() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.openStoreListing(appStoreId: _playStorePackageName);
        return;
      }
    } catch (e) {
      debugPrint('ReviewService: in_app_review failed, using url_launcher: $e');
    }

    // Direct store intent & web fallback
    final marketUri = Uri.parse('market://details?id=$_playStorePackageName');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$_playStorePackageName&hl=en');

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('ReviewService: Could not launch Play Store URL: $e');
    }
  }

  /// Call this on app open. Shows review dialog after [openThreshold] opens.
  Future<void> checkAndRequestReview({
    LocalStorageService? storage,
    int openThreshold = 5,
  }) async {
    try {
      final localStorage = storage ?? await LocalStorageService.getInstance();

      // Increment open count
      await localStorage.incrementAppOpenCount();
      final openCount = localStorage.getAppOpenCount();

      // Already shown or already rated → skip
      if (localStorage.hasShownReview() || localStorage.hasRatedApp()) return;

      // Not enough opens yet → skip
      if (openCount < openThreshold) return;

      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) return;

      await localStorage.setHasShownReview();
      await Future.delayed(const Duration(seconds: 1));

      await _inAppReview.requestReview();
    } catch (e) {
      debugPrint('ReviewService: Error requesting review: $e');
    }
  }
}
