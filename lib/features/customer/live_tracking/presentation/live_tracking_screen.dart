import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../presentation/delivery_notifier.dart';

class LiveTrackingScreen extends ConsumerWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryNotifierProvider);
    final delivery = deliveryState.activeDelivery;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Track Order',
            style: AppTypography.headlineMedium(
                color: theme.colorScheme.onSurface)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View
          const Positioned.fill(
            child: SimulatedMapWidget(
              showRoute: true,
            ),
          ),

          // Floating ESTIMATED ARRIVAL Card Top
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ESTIMATED ARRIVAL',
                              style: AppTypography.labelMedium(
                                  color: AppColors.primary)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${delivery?.estimatedArrivalMins ?? 12}',
                                style: AppTypography.displayMedium(
                                    color: theme.colorScheme.onSurface),
                              ),
                              const SizedBox(width: 4),
                              Text('mins',
                                  style: AppTypography.titleLarge(
                                      color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ],
                      ),
                      StatusBadge.onTheWay(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Horizontal 4-Step Stepper
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StepItem(title: 'Ordered', isDone: true),
                      _StepItem(title: 'Picked up', isDone: true),
                      _StepItem(title: 'On the way', isActive: true),
                      _StepItem(title: 'Arriving', isDone: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rider Info Card Bottom Overlay
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Rider Photo Avatar
                      const Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryMint,
                            child: Icon(Icons.person,
                                size: 36, color: AppColors.primary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(Icons.verified,
                                color: AppColors.primary, size: 18),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Rider Name & Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery?.assignedRiderName ?? 'Rider Accepted',
                              style: AppTypography.titleLarge(
                                  color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${delivery?.assignedRiderRating ?? 5.0}',
                                  style: AppTypography.bodySmall(
                                      color: AppColors.accentOrangeDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Quick Chat Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.parcelBg,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: AppColors.primary),
                        onPressed: () {},
                      ),

                      const SizedBox(width: 8),

                      // Quick Call Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.phone, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Simulate Completion CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/order-completion'),
                      child: Text('Complete Order',
                          style: AppTypography.labelLarge(
                              color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/customer');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final bool isActive;

  const _StepItem({
    required this.title,
    this.isDone = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.statusSuccess
                : (isActive ? AppColors.primary : AppColors.cardBorder),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : (isActive
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTypography.bodySmall(
            color: isDone || isActive
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
