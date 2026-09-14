import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class FeatureBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTryNow;

  const FeatureBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag = 'TRENDING',
    required this.icon,
    required this.gradientColors,
    required this.onTryNow,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = gradientColors.first;
    final secondaryColor = gradientColors.length > 1 ? gradientColors[1] : gradientColors.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTryNow,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  secondaryColor,
                  if (gradientColors.length > 2) gradientColors[2] else secondaryColor.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                // Top-right glowing radial aura
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom-right glow
                Positioned(
                  right: 20,
                  bottom: -40,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Stylized Floating Icon Graphic in Background
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 46,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tag.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title & Subtitle
                      Padding(
                        padding: const EdgeInsets.only(right: 90),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Explore Action Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Now',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              LucideIcons.arrowRight,
                              size: 13,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
