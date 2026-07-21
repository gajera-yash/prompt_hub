import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import '../core/theme/app_colors.dart';
import '../models/prompt_model.dart';
import '../providers/data_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _exportBackup(BuildContext context, WidgetRef ref) {
    final customPrompts = ref.read(customPromptsProvider);
    if (customPrompts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No custom prompts available to export'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final jsonList = customPrompts.map((p) => p.toJson()).toList();
    final jsonStr = json.encode(jsonList);

    Clipboard.setData(ClipboardData(text: jsonStr));
    SharePlus.instance.share(
      ShareParams(text: jsonStr, title: 'AI Prompt Hub Backup'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup JSON copied to clipboard & share menu opened!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _importBackup(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup (JSON)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste your exported JSON backup text below to restore your custom prompts:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste JSON text here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  final List<dynamic> decoded = json.decode(text);
                  int count = 0;
                  for (final item in decoded) {
                    if (item is Map<String, dynamic>) {
                      final prompt = PromptModel.fromJson(item);
                      ref.read(customPromptsProvider.notifier).saveCustomPrompt(prompt);
                      count++;
                    }
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully restored $count custom prompts!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid JSON backup format. Please check the text.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                color: AppColors.accent.withValues(alpha: 0.1),
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
            final url = Uri.parse('https://play.google.com/store/apps/details?id=com.ai_prompt_hub.setuvio&hl=en');
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
      trailing: Icon(LucideIcons.chevronRight, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }
}
