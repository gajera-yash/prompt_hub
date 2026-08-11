import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';

class VoiceInputDialog extends StatefulWidget {
  final Function(String text) onSpeechResult;
  const VoiceInputDialog({super.key, required this.onSpeechResult});

  static Future<void> show(
    BuildContext context, {
    required Function(String text) onSpeechResult,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => VoiceInputDialog(onSpeechResult: onSpeechResult),
    );
  }

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  bool _isListening = true;
  String _transcript = '';

  final List<String> _samplePrompts = [
    'Act as an expert marketing strategist for a new mobile application.',
    'Write a production-ready Flutter custom widget for animated cards.',
    'Generate a Midjourney prompt for a photorealistic 3D futuristic logo.',
    'Explain quantum computing concepts simply to a 10-year-old child.',
  ];

  void _selectSample(String text) {
    widget.onSpeechResult(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Mic Wave Effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(LucideIcons.mic, color: Colors.white, size: 36),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 800.ms, begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
            const SizedBox(height: 20),

            Text(
              _isListening ? 'Listening to your voice...' : 'Speech captured',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Speak your prompt or pick a quick voice template below:',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textMuted : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Voice Samples Chips
            Column(
              children: _samplePrompts.map((sample) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectSample(sample),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.border : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.volume2, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              sample,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
