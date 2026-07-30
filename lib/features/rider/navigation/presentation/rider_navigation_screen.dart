import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../presentation/rider_notifier.dart';

class RiderNavigationScreen extends ConsumerStatefulWidget {
  const RiderNavigationScreen({super.key});

  @override
  ConsumerState<RiderNavigationScreen> createState() =>
      _RiderNavigationScreenState();
}

class _RiderNavigationScreenState extends ConsumerState<RiderNavigationScreen> {
  bool _isPickedUp = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(riderNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Interactive Map Canvas
          const Positioned.fill(
            child: SimulatedMapWidget(
              showRoute: true,
            ),
          ),

          // Floating Top Turn-by-Turn Instruction Banner
          Positioned(
            top: 48,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.turn_right,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('300M',
                            style: AppTypography.labelMedium(
                                color: Colors.white70)),
                        Text(
                          'Turn right onto KN 5 Rd',
                          style: AppTypography.titleLarge(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Floating Map Tools (Right Side)
          Positioned(
            right: 20,
            top: 140,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'map_target',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child:
                      const Icon(Icons.my_location, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'map_layers',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: const Icon(Icons.layers_outlined,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Bottom Navigation Controls Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 16),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer Summary Tile
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryMint,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer',
                                style: AppTypography.titleLarge(
                                    color: theme.colorScheme.onSurface)),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: AppTypography.bodySmall(
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.parcelBg,
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(Icons.phone, color: AppColors.primary),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.parcelBg,
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Metrics Grid (3 Cards)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.parcelBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('ETA',
                                  style: AppTypography.labelMedium(
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text('4 min',
                                  style: AppTypography.headlineMedium(
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.parcelBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('DISTANCE',
                                  style: AppTypography.labelMedium(
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text('1.2 km',
                                  style: AppTypography.headlineMedium(
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.parcelBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('TRAFFIC',
                                  style: AppTypography.labelMedium(
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text('Light',
                                  style: AppTypography.headlineMedium(
                                      color: AppColors.accentOrange)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: _isPickedUp ? 'Complete Delivery' : 'Picked Up',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      if (!_isPickedUp) {
                        setState(() => _isPickedUp = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Order marked as Picked Up! Navigating to dropoff...')),
                        );
                      } else {
                        notifier.completeCurrentJob(2500);
                        context.go('/earnings');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
