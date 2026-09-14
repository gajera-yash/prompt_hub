import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'local_storage_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._();
  ReviewService._();
  static ReviewService get instance => _instance;

  final InAppReview _inAppReview = InAppReview.instance;

  /// Call this on each app open. Will show review dialog after [openThreshold] opens,
  /// and only once per installation (tracked in SharedPreferences).
  Future<void> checkAndRequestReview({
    LocalStorageService? storage,
    int openThreshold = 5,
  }) async {
    try {
      final localStorage = storage ?? await LocalStorageService.getInstance();

      // Increment open count
      await localStorage.incrementAppOpenCount();
      final openCount = localStorage.getAppOpenCount();

      // Already shown → skip
      if (localStorage.hasShownReview()) return;

      // Not enough opens yet → skip
      if (openCount < openThreshold) return;

      // Check if in-app review is available on this device
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) return;

      // Mark as shown BEFORE requesting (avoids race conditions)
      await localStorage.setHasShownReview();

      // Small delay so it doesn't feel abrupt
      await Future.delayed(const Duration(seconds: 1));

      await _inAppReview.requestReview();
    } catch (e) {
      debugPrint('ReviewService: Error requesting review: $e');
    }
  }
}
