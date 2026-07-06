import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/data_providers.dart';

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
          _buildListTile(context, LucideIcons.info, 'App Version', () {}, subtitle: 'v1.0.0'),
          _buildListTile(context, LucideIcons.star, 'Rate App', () async {
            final url = Uri.parse('https://play.google.com/store/apps/details?id=com.setuvio.ai_prompt_hub&hl=en');
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Could not launch $url');
            }
          }),
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
