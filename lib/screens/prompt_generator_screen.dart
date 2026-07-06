import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/gradient_button.dart';
import 'package:go_router/go_router.dart';
import '../widgets/banner_ad_widget.dart';

class PromptGeneratorScreen extends StatefulWidget {
  const PromptGeneratorScreen({super.key});

  @override
  State<PromptGeneratorScreen> createState() => _PromptGeneratorScreenState();
}

class _PromptGeneratorScreenState extends State<PromptGeneratorScreen> {
  final _inputController = TextEditingController();
  String? _generatedPrompt;
  bool _isGenerating = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _generatePrompt() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tell us what you want to generate')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedPrompt = null;
    });

    // Simulate API delay for a premium AI generation feel
    await Future.delayed(const Duration(milliseconds: 2000));

    // Generate a high quality detailed prompt structure based on user input
    String generated = '''Act as an absolute expert in the relevant field. 

**Task:**
I need you to create a comprehensive, high-quality response based on the following core requirement: "$input".

**Context & Background:**
- Treat this as a high-stakes professional request.
- The output should be tailored to achieve maximum impact, clarity, and depth.
- If there are underlying concepts, explain them intuitively but rigorously.

**Tone & Style:**
- Maintain an authoritative, engaging, and professional tone.
- Avoid generic filler text; every sentence must add value.

**Format Requirements:**
- Structure your response using clear headings, bullet points, and short paragraphs.
- Use bold text to highlight key takeaways.
- Include a brief executive summary at the beginning and actionable next steps at the end.

Please begin your response now by acknowledging this role and delivering the requested content.''';

    if (mounted) {
      setState(() {
        _generatedPrompt = generated;
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedPrompt != null) {
      Clipboard.setData(ClipboardData(text: _generatedPrompt!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Custom Prompt AI'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Hero Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Architect',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Turn simple ideas into master-level prompts instantly.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Single Large Input
              Text(
                'What do you want to achieve?',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.borderLightTheme,
                    width: 1.5,
                  ),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 5,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'e.g., Write a highly converting landing page copy for a SaaS product...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: _isGenerating ? () {} : _generatePrompt,
                  text: _isGenerating ? 'Architecting Prompt...' : 'Generate High-Quality Prompt',
                  icon: _isGenerating ? LucideIcons.loader : LucideIcons.wand2,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const BannerAdWidget(),
              const SizedBox(height: AppSpacing.xl),

              // Result Area
              if (_generatedPrompt != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Optimized Prompt',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(LucideIcons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.borderLightTheme,
                    ),
                  ),
                  child: SelectableText(
                    _generatedPrompt!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
