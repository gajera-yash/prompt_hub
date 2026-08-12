import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/data_providers.dart';
import '../widgets/prompt_card.dart';
import '../models/prompt_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(notificationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (prompts) {
          if (prompts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                return ref.refresh(notificationHistoryProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bellOff, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No notifications', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(notificationHistoryProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final item = prompts[index];
                final prompt = item['prompt'] as PromptModel;
                final time = DateTime.fromMillisecondsSinceEpoch(item['time']);
                
                String formatTime(DateTime t) {
                  final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
                  final m = t.minute.toString().padLeft(2, '0');
                  final p = t.hour >= 12 ? 'PM' : 'AM';
                  return '$h:$m $p';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Today at ${formatTime(time)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PromptCard(
                        prompt: prompt,
                        onTap: () => context.push('/prompt/${prompt.id}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
