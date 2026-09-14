import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_update/in_app_update.dart';
import '../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdateAndNavigate();
  }

  Future<void> _checkForUpdateAndNavigate() async {
    bool shouldUpdate = false;
    try {
      // Skip update check in debug mode or add timeout
      if (Theme.of(context).platform == TargetPlatform.android) {
        // We use a timeout to prevent the app from hanging on the splash screen
        final updateInfo = await InAppUpdate.checkForUpdate().timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw Exception('Update check timed out'),
        );
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable ||
            updateInfo.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
          shouldUpdate = true;
        }
      }
    } catch (e) {
      debugPrint('Check for update failed (network/play store issue): $e');
      _navigateToNext();
      return;
    }

    if (shouldUpdate) {
      try {
        await InAppUpdate.performImmediateUpdate();
        if (mounted) _checkForUpdateAndNavigate(); 
      } catch (e) {
        debugPrint('Perform update failed (user cancelled or error): $e');
        // Do not force infinite loop, just proceed if update fails
        _navigateToNext();
      }
      return;
    }
    
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      final storage = await LocalStorageService.getInstance();
      
      // FOR TESTING: Reset onboarding status so it shows every time
      // await storage.setHasSeenOnboarding(false);
      
      final hasSeen = storage.hasSeenOnboarding();
      final hasPreferences = storage.getUserPreferences() != null;

      // Show onboarding if:
      // 1. User has never seen onboarding, OR
      // 2. hasSeenOnboarding is true but no preferences were saved (old buggy version set the flag prematurely)
      if (!hasSeen || !hasPreferences) {
        if (mounted) context.go('/onboarding');
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glows
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3)),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 56,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack, begin: const Offset(0, 0))
                    .then()
                    .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(height: 32),
                const Text(
                  'AI Prompt Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Supercharge your AI workflow',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ).animate().fade(delay: 600.ms, duration: 600.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
