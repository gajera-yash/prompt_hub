import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/ad_helper.dart';
import '../services/local_storage_service.dart';
import '../widgets/gradient_button.dart';

class CustomPromptScreen extends StatefulWidget {
  const CustomPromptScreen({super.key});

  @override
  State<CustomPromptScreen> createState() => _CustomPromptScreenState();
}

class _CustomPromptScreenState extends State<CustomPromptScreen> {
  final _promptController = TextEditingController();
  LocalStorageService? _storage;
  int _dailyCount = 0;
  bool _isWatchingAd = false;

  @override
  void initState() {
    super.initState();
    _loadDailyCount();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyCount() async {
    final storage = await LocalStorageService.getInstance();
    if (mounted) {
      setState(() {
        _storage = storage;
        _dailyCount = storage.getDailyPromptCount();
      });
    }
  }

  int get _remainingFree {
    return LocalStorageService.dailyFreePromptLimit - _dailyCount;
  }

  bool get _hasReachedLimit => _dailyCount >= LocalStorageService.dailyFreePromptLimit;

  Future<void> _handleCopyPrompt() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a prompt first')),
      );
      return;
    }

    if (_hasReachedLimit) {
      _showRewardedAdDialog();
      return;
    }

    await _copyPrompt();
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: _promptController.text));
    await _storage?.incrementDailyPromptCount();
    if (mounted) {
      setState(() {
        _dailyCount = _storage?.getDailyPromptCount() ?? _dailyCount + 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt copied!')),
      );
    }
  }

  void _showRewardedAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.lock, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text('Daily Limit Reached'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve used all ${LocalStorageService.dailyFreePromptLimit} free prompts today.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Watch a rewarded ad to generate more prompts!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _isWatchingAd ? null : _watchRewardedAd,
            icon: _isWatchingAd
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.play, size: 18),
            label: Text(_isWatchingAd ? 'Loading...' : 'Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _watchRewardedAd() {
    setState(() => _isWatchingAd = true);

    AdHelper.showRewardedAd(
      onUserEarnedReward: (reward) {
        // User earned reward - allow prompt generation
        if (mounted) {
          Navigator.pop(context); // Close dialog
          _copyPrompt();
        }
      },
      onAdDismissed: () {
        if (mounted) {
          setState(() => _isWatchingAd = false);
        }
      },
    );
  }

  Widget _buildLimitIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _hasReachedLimit
            ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasReachedLimit
              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _hasReachedLimit ? LucideIcons.lock : LucideIcons.zap,
            color: _hasReachedLimit ? const Color(0xFFF59E0B) : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasReachedLimit
                      ? 'Daily limit reached'
                      : 'Free prompts remaining',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _hasReachedLimit
                      ? 'Watch an ad to generate more'
                      : '$_remainingFree of ${LocalStorageService.dailyFreePromptLimit} left today',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!_hasReachedLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_remainingFree',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLimitIndicator(),
            const SizedBox(height: 20),
            Text('Write your prompt', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _promptController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Type your prompt here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: _hasReachedLimit ? 'Watch Ad to Copy' : 'Copy Prompt',
                icon: _hasReachedLimit ? LucideIcons.play : LucideIcons.copy,
                onPressed: _handleCopyPrompt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}