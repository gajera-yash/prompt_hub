import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/data_providers.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class TrendingPhotosScreen extends ConsumerWidget {
  const TrendingPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(trendingPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Photos'),
      ),
      body: photos.isEmpty
          ? const Center(child: Text('No trending photos found.'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(trendingPhotosProvider.notifier).refresh();
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return GestureDetector(
                    onTap: () => context.push('/prompt/${photo.id}'),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        color: AppColors.surface,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (photo.imageUrl != null && photo.imageUrl!.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: photo.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surface,
                                child: const Center(
                                  child: Icon(LucideIcons.image, color: AppColors.textMuted, size: 32),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surface,
                                child: const Center(
                                  child: Icon(LucideIcons.imageOff, color: AppColors.textMuted, size: 32),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.85),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Text(
                                photo.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
