import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_update/in_app_update.dart';
import '../core/theme/app_colors.dart';
import '../providers/data_providers.dart';
import '../widgets/review_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final notificationsEnabled = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Appearance
          _buildSectionTitle(context, 'Appearance'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(isDark ? LucideIcons.moon : LucideIcons.sun, size: 20, color: AppColors.primary),
            ),
            title: Text('Dark Mode', style: theme.textTheme.titleSmall),
            subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled', style: theme.textTheme.bodySmall),
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),

          const Divider(indent: 24, endIndent: 24),

          // Notifications
          _buildSectionTitle(context, 'Notifications'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.bell, size: 20, color: AppColors.accent),
            ),
            title: Text('Push Notifications', style: theme.textTheme.titleSmall),
            subtitle: const Text('Receive daily prompt suggestions'),
            value: notificationsEnabled,
            onChanged: (value) {
              ref.read(notificationsProvider.notifier).toggle();
            },
          ),

          const Divider(indent: 24, endIndent: 24),

          // About
          _buildSectionTitle(context, 'About'),
          _buildListTile(context, LucideIcons.shieldCheck, 'Privacy Policy', () async {
            final url = Uri.parse('https://docs.google.com/document/d/1sEhPm5oB0KijOraKY2wpYYsTd-6OAU7bABBp32aVd0g/edit?usp=sharing');
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Could not launch $url');
            }
          }),
          _buildListTile(context, LucideIcons.fileText, 'Terms & Conditions', () {
            context.push('/terms');
          }),
          _buildListTile(
            context,
            LucideIcons.info,
            'App Version',
            () => _handleCheckForUpdate(context),
            subtitle: 'v1.2.0 (Check for updates)',
          ),
          _buildListTile(context, LucideIcons.star, 'Rate App', () {
            ReviewDialog.show(context);
          }),
        ],
      ),
    );
  }

  Future<void> _handleCheckForUpdate(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Checking for updates...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final updateInfo = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 4),
      );

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Update Available'),
            content: const Text('A new version of AI Prompt Hub is available. Would you like to update now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await InAppUpdate.performImmediateUpdate();
                  } catch (_) {
                    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.ai_prompt_hub.setuvio&hl=en');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      } else {
        if (!context.mounted) return;
        _showUpToDateDialog(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showUpToDateDialog(context);
    }
  }

  void _showUpToDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: AppColors.accentGreen, size: 24),
            SizedBox(width: 10),
            Text('Up to Date'),
          ],
        ),
        content: const Text('You are using the latest version of AI Prompt Hub (v1.2.0).'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final url = Uri.parse('https://play.google.com/store/apps/details?id=com.ai_prompt_hub.setuvio&hl=en');
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: const Text('Play Store'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(LucideIcons.chevronRight, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
