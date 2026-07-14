import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/gradient_button.dart';
import '../core/theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withOpacity(0.1),
              ),
              child: const Icon(LucideIcons.crown, size: 64, color: AppColors.warning),
            ),
            const SizedBox(height: 24),
            Text('Go Premium', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Unlock limitless possibilities and boost your productivity.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildFeatureRow(context, 'Unlimited Prompts Access'),
            _buildFeatureRow(context, 'No Ads Experience'),
            _buildFeatureRow(context, 'Exclusive Premium Categories'),
            _buildFeatureRow(context, 'Early Access to New Features'),
            
            const SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(child: _buildPlanCard(context, 'Monthly', '\$4.99', '/mo', false)),
                const SizedBox(width: 16),
                Expanded(child: _buildPlanCard(context, 'Yearly', '\$39.99', '/yr', true)),
              ],
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Upgrade Now',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleSmall)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, String period, bool isSelected) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (isSelected) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('SAVE 30%', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : null)),
              Text(period, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
