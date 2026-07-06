import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection(theme, '1. Introduction', 
              'Welcome to AI Prompt Hub. By accessing and using this application, you accept and agree to be bound by the terms and provisions of this agreement.'),
            
            _buildSection(theme, '2. License to Use', 
              'We grant you a personal, non-exclusive, non-transferable, limited privilege to enter and use the App. The prompts provided are for educational and inspirational purposes.'),
            
            _buildSection(theme, '3. User Content', 
              'Users may generate and use prompts. However, you are solely responsible for the content you generate using third-party AI models (like ChatGPT, Midjourney, etc.) based on our prompts.'),
            
            _buildSection(theme, '4. Intellectual Property', 
              'The application, its original content, features, and functionality are owned by Setuvio and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.'),
            
            _buildSection(theme, '5. Disclaimers', 
              'The app is provided on an "as is" and "as available" basis. We make no warranties, expressed or implied, regarding the accuracy or reliability of the AI-generated outputs derived from our prompts.'),
              
            _buildSection(theme, '6. Changes to Terms', 
              'We reserve the right to modify or replace these Terms at any time. We will try to provide at least 30 days notice prior to any new terms taking effect.'),
              
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text(
                '© ${DateTime.now().year} Setuvio. All rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
